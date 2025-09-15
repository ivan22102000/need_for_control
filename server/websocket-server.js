const WebSocket = require('ws');
const express = require('express');
const http = require('http');
const path = require('path');

// Configuration
const PORT = 8080;
const WS_PATH = '/racing';

// Create Express app
const app = express();
const server = http.createServer(app);

// Create WebSocket server
const wss = new WebSocket.Server({ 
  server,
  path: WS_PATH 
});

// Store connected devices and clients
const connectedDevices = new Map(); // ESP32 controllers
const connectedClients = new Map(); // Android/Web clients
const gameRooms = new Map(); // Game sessions

// Serve static files (for web client testing)
app.use(express.static(path.join(__dirname, 'public')));

// API endpoints
app.get('/api/devices', (req, res) => {
  const devices = Array.from(connectedDevices.values()).map(device => ({
    deviceId: device.deviceId,
    deviceType: device.deviceType,
    connected: true,
    lastSeen: device.lastSeen
  }));
  res.json(devices);
});

app.get('/api/rooms', (req, res) => {
  const rooms = Array.from(gameRooms.values()).map(room => ({
    roomId: room.roomId,
    players: room.players.length,
    devices: room.devices.length,
    status: room.status
  }));
  res.json(rooms);
});

// WebSocket connection handler
wss.on('connection', (ws, req) => {
  console.log('New WebSocket connection from:', req.connection.remoteAddress);
  
  let clientInfo = {
    id: generateId(),
    type: 'unknown',
    lastSeen: Date.now()
  };
  
  ws.on('message', (data) => {
    try {
      const message = JSON.parse(data.toString());
      handleMessage(ws, message, clientInfo);
    } catch (error) {
      console.error('Error parsing message:', error);
      sendError(ws, 'Invalid JSON format');
    }
  });
  
  ws.on('close', () => {
    handleDisconnection(clientInfo);
  });
  
  ws.on('error', (error) => {
    console.error('WebSocket error:', error);
  });
  
  // Send welcome message
  sendMessage(ws, {
    type: 'connection_established',
    clientId: clientInfo.id,
    timestamp: Date.now()
  });
});

function handleMessage(ws, message, clientInfo) {
  clientInfo.lastSeen = Date.now();
  
  console.log('Received message:', message.type, 'from:', clientInfo.id);
  
  switch (message.type) {
    case 'device_registration':
      handleDeviceRegistration(ws, message, clientInfo);
      break;
      
    case 'client_registration':
      handleClientRegistration(ws, message, clientInfo);
      break;
      
    case 'control_data':
      handleControlData(ws, message, clientInfo);
      break;
      
    case 'join_room':
      handleJoinRoom(ws, message, clientInfo);
      break;
      
    case 'create_room':
      handleCreateRoom(ws, message, clientInfo);
      break;
      
    case 'game_command':
      handleGameCommand(ws, message, clientInfo);
      break;
      
    case 'pong':
      // Handle ping response
      break;
      
    default:
      console.log('Unknown message type:', message.type);
      sendError(ws, 'Unknown message type');
  }
}

function handleDeviceRegistration(ws, message, clientInfo) {
  clientInfo.type = 'device';
  clientInfo.deviceId = message.deviceId;
  clientInfo.deviceType = message.deviceType;
  clientInfo.capabilities = message.capabilities;
  clientInfo.version = message.version;
  clientInfo.ws = ws;
  
  connectedDevices.set(message.deviceId, clientInfo);
  
  sendMessage(ws, {
    type: 'registration_success',
    deviceId: message.deviceId,
    message: 'Device registered successfully'
  });
  
  console.log(`Device registered: ${message.deviceId} (${message.deviceType})`);
  
  // Notify all clients about new device
  broadcastToClients({
    type: 'device_connected',
    device: {
      deviceId: message.deviceId,
      deviceType: message.deviceType,
      capabilities: message.capabilities
    }
  });
}

function handleClientRegistration(ws, message, clientInfo) {
  clientInfo.type = 'client';
  clientInfo.clientId = message.clientId;
  clientInfo.clientType = message.clientType;
  clientInfo.playerName = message.playerName;
  clientInfo.ws = ws;
  
  connectedClients.set(message.clientId, clientInfo);
  
  sendMessage(ws, {
    type: 'registration_success',
    clientId: message.clientId,
    availableDevices: Array.from(connectedDevices.keys())
  });
  
  console.log(`Client registered: ${message.clientId} (${message.clientType})`);
}

function handleControlData(ws, message, clientInfo) {
  if (clientInfo.type !== 'device') {
    sendError(ws, 'Only devices can send control data');
    return;
  }
  
  // Forward control data to all clients in the same room
  const deviceId = clientInfo.deviceId;
  const room = findRoomByDevice(deviceId);
  
  if (room) {
    const controlMessage = {
      type: 'control_update',
      deviceId: deviceId,
      steering: message.steering,
      normalizedSteering: message.normalizedSteering,
      button: message.button,
      timestamp: message.timestamp
    };
    
    // Send to all clients in the room
    room.players.forEach(playerId => {
      const client = connectedClients.get(playerId);
      if (client && client.ws.readyState === WebSocket.OPEN) {
        sendMessage(client.ws, controlMessage);
      }
    });
  }
}

function handleJoinRoom(ws, message, clientInfo) {
  const roomId = message.roomId;
  const room = gameRooms.get(roomId);
  
  if (!room) {
    sendError(ws, 'Room not found');
    return;
  }
  
  if (clientInfo.type === 'client') {
    room.players.push(clientInfo.clientId);
  } else if (clientInfo.type === 'device') {
    room.devices.push(clientInfo.deviceId);
  }
  
  sendMessage(ws, {
    type: 'room_joined',
    roomId: roomId,
    room: {
      players: room.players.length,
      devices: room.devices.length
    }
  });
  
  console.log(`${clientInfo.type} ${clientInfo.clientId || clientInfo.deviceId} joined room ${roomId}`);
}

function handleCreateRoom(ws, message, clientInfo) {
  const roomId = message.roomId || generateRoomId();
  
  const room = {
    roomId: roomId,
    createdBy: clientInfo.clientId,
    players: [clientInfo.clientId],
    devices: [],
    status: 'waiting',
    createdAt: Date.now()
  };
  
  gameRooms.set(roomId, room);
  
  sendMessage(ws, {
    type: 'room_created',
    roomId: roomId,
    room: room
  });
  
  console.log(`Room created: ${roomId} by ${clientInfo.clientId}`);
}

function handleGameCommand(ws, message, clientInfo) {
  if (clientInfo.type !== 'client') {
    sendError(ws, 'Only clients can send game commands');
    return;
  }
  
  const room = findRoomByPlayer(clientInfo.clientId);
  if (!room) {
    sendError(ws, 'Not in a room');
    return;
  }
  
  // Forward game feedback to connected devices
  const gameMessage = {
    type: 'game_feedback',
    command: message.command,
    data: message.data,
    timestamp: Date.now()
  };
  
  room.devices.forEach(deviceId => {
    const device = connectedDevices.get(deviceId);
    if (device && device.ws.readyState === WebSocket.OPEN) {
      sendMessage(device.ws, gameMessage);
    }
  });
}

function handleDisconnection(clientInfo) {
  if (clientInfo.type === 'device') {
    connectedDevices.delete(clientInfo.deviceId);
    console.log(`Device disconnected: ${clientInfo.deviceId}`);
    
    // Notify clients
    broadcastToClients({
      type: 'device_disconnected',
      deviceId: clientInfo.deviceId
    });
    
  } else if (clientInfo.type === 'client') {
    connectedClients.delete(clientInfo.clientId);
    console.log(`Client disconnected: ${clientInfo.clientId}`);
  }
  
  // Remove from rooms
  removeFromRooms(clientInfo);
}

function sendMessage(ws, message) {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(message));
  }
}

function sendError(ws, error) {
  sendMessage(ws, {
    type: 'error',
    error: error,
    timestamp: Date.now()
  });
}

function broadcastToClients(message) {
  connectedClients.forEach((client) => {
    if (client.ws.readyState === WebSocket.OPEN) {
      sendMessage(client.ws, message);
    }
  });
}

function findRoomByDevice(deviceId) {
  for (const room of gameRooms.values()) {
    if (room.devices.includes(deviceId)) {
      return room;
    }
  }
  return null;
}

function findRoomByPlayer(clientId) {
  for (const room of gameRooms.values()) {
    if (room.players.includes(clientId)) {
      return room;
    }
  }
  return null;
}

function removeFromRooms(clientInfo) {
  gameRooms.forEach((room, roomId) => {
    if (clientInfo.type === 'client') {
      const index = room.players.indexOf(clientInfo.clientId);
      if (index > -1) {
        room.players.splice(index, 1);
      }
    } else if (clientInfo.type === 'device') {
      const index = room.devices.indexOf(clientInfo.deviceId);
      if (index > -1) {
        room.devices.splice(index, 1);
      }
    }
    
    // Remove empty rooms
    if (room.players.length === 0 && room.devices.length === 0) {
      gameRooms.delete(roomId);
      console.log(`Room ${roomId} deleted (empty)`);
    }
  });
}

function generateId() {
  return Math.random().toString(36).substr(2, 9);
}

function generateRoomId() {
  return 'room_' + Math.random().toString(36).substr(2, 6).toUpperCase();
}

// Ping connected clients periodically
setInterval(() => {
  const pingMessage = {
    type: 'ping',
    timestamp: Date.now()
  };
  
  connectedDevices.forEach((device) => {
    if (device.ws.readyState === WebSocket.OPEN) {
      sendMessage(device.ws, pingMessage);
    }
  });
  
  connectedClients.forEach((client) => {
    if (client.ws.readyState === WebSocket.OPEN) {
      sendMessage(client.ws, pingMessage);
    }
  });
}, 30000); // Every 30 seconds

// Clean up stale connections
setInterval(() => {
  const now = Date.now();
  const timeout = 60000; // 1 minute
  
  connectedDevices.forEach((device, deviceId) => {
    if (now - device.lastSeen > timeout) {
      console.log(`Removing stale device: ${deviceId}`);
      connectedDevices.delete(deviceId);
    }
  });
  
  connectedClients.forEach((client, clientId) => {
    if (now - client.lastSeen > timeout) {
      console.log(`Removing stale client: ${clientId}`);
      connectedClients.delete(clientId);
    }
  });
}, 60000); // Every minute

// Start server
server.listen(PORT, () => {
  console.log('=================================');
  console.log('Racing Game WebSocket Server');
  console.log('=================================');
  console.log(`Server running on port ${PORT}`);
  console.log(`WebSocket endpoint: ws://localhost:${PORT}${WS_PATH}`);
  console.log(`Web interface: http://localhost:${PORT}`);
  console.log('');
  console.log('Waiting for connections...');
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down server...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

module.exports = { app, server, wss };
