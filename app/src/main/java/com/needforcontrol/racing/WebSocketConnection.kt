package com.needforcontrol.racing

import android.content.Context
import android.util.Log
import kotlinx.coroutines.*
import okhttp3.*
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class WebSocketConnection(
    private val context: Context,
    private val listener: WebSocketConnectionListener
) {
    private var webSocket: WebSocket? = null
    private var okHttpClient: OkHttpClient? = null
    private var connected = false
    private var connectionJob: Job? = null
    
    // Server configuration - CHANGE THESE!
    private val serverUrl = "ws://192.168.1.100:8080/racing"  // Change to your server IP
    private val clientId = "android_${System.currentTimeMillis()}"
    private val playerName = "Android Player"
    
    private var steeringListener: ((Float) -> Unit)? = null
    private var buttonListener: ((Boolean) -> Unit)? = null
    
    interface WebSocketConnectionListener {
        fun onConnectionStateChanged(connected: Boolean)
        fun onDataReceived(data: String)
        fun onError(message: String)
        fun onDeviceConnected(deviceId: String, deviceType: String)
        fun onDeviceDisconnected(deviceId: String)
    }
    
    init {
        setupOkHttpClient()
    }
    
    private fun setupOkHttpClient() {
        okHttpClient = OkHttpClient.Builder()
            .pingInterval(30, TimeUnit.SECONDS)
            .retryOnConnectionFailure(true)
            .build()
    }
    
    fun setSteeringListener(listener: (Float) -> Unit) {
        steeringListener = listener
    }
    
    fun setButtonListener(listener: (Boolean) -> Unit) {
        buttonListener = listener
    }
    
    fun connect() {
        if (connected) {
            Log.w("WebSocketConnection", "Already connected")
            return
        }
        
        connectionJob = CoroutineScope(Dispatchers.IO).launch {
            try {
                val request = Request.Builder()
                    .url(serverUrl)
                    .build()
                
                webSocket = okHttpClient?.newWebSocket(request, object : WebSocketListener() {
                    override fun onOpen(webSocket: WebSocket, response: Response) {
                        Log.i("WebSocketConnection", "Connected to server")
                        connected = true
                        
                        // Notify connection state change on main thread
                        CoroutineScope(Dispatchers.Main).launch {
                            listener.onConnectionStateChanged(true)
                        }
                        
                        // Register as client
                        registerClient()
                    }
                    
                    override fun onMessage(webSocket: WebSocket, text: String) {
                        Log.d("WebSocketConnection", "Received: $text")
                        
                        CoroutineScope(Dispatchers.Main).launch {
                            listener.onDataReceived(text)
                            processMessage(text)
                        }
                    }
                    
                    override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
                        Log.i("WebSocketConnection", "Connection closing: $reason")
                    }
                    
                    override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
                        Log.i("WebSocketConnection", "Connection closed: $reason")
                        connected = false
                        
                        CoroutineScope(Dispatchers.Main).launch {
                            listener.onConnectionStateChanged(false)
                        }
                    }
                    
                    override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                        Log.e("WebSocketConnection", "Connection failed", t)
                        connected = false
                        
                        CoroutineScope(Dispatchers.Main).launch {
                            listener.onConnectionStateChanged(false)
                            listener.onError("Connection failed: ${t.message}")
                        }
                        
                        // Attempt to reconnect after delay
                        scheduleReconnect()
                    }
                })
                
            } catch (e: Exception) {
                Log.e("WebSocketConnection", "Error creating connection", e)
                CoroutineScope(Dispatchers.Main).launch {
                    listener.onError("Connection error: ${e.message}")
                }
            }
        }
    }
    
    private fun registerClient() {
        val registrationMessage = JSONObject().apply {
            put("type", "client_registration")
            put("clientId", clientId)
            put("clientType", "android_app")
            put("playerName", playerName)
        }
        
        sendMessage(registrationMessage.toString())
        Log.d("WebSocketConnection", "Client registration sent")
    }
    
    private fun processMessage(message: String) {
        try {
            val json = JSONObject(message)
            val messageType = json.getString("type")
            
            when (messageType) {
                "registration_success" -> {
                    Log.i("WebSocketConnection", "Registration successful")
                    if (json.has("availableDevices")) {
                        val devices = json.getJSONArray("availableDevices")
                        Log.d("WebSocketConnection", "Available devices: $devices")
                    }
                }
                
                "control_update" -> {
                    processControlUpdate(json)
                }
                
                "device_connected" -> {
                    val device = json.getJSONObject("device")
                    val deviceId = device.getString("deviceId")
                    val deviceType = device.getString("deviceType")
                    
                    Log.i("WebSocketConnection", "Device connected: $deviceId")
                    listener.onDeviceConnected(deviceId, deviceType)
                }
                
                "device_disconnected" -> {
                    val deviceId = json.getString("deviceId")
                    Log.i("WebSocketConnection", "Device disconnected: $deviceId")
                    listener.onDeviceDisconnected(deviceId)
                }
                
                "room_joined" -> {
                    val roomId = json.getString("roomId")
                    Log.i("WebSocketConnection", "Joined room: $roomId")
                }
                
                "room_created" -> {
                    val roomId = json.getString("roomId")
                    Log.i("WebSocketConnection", "Room created: $roomId")
                }
                
                "game_feedback" -> {
                    // Handle game feedback if needed
                    Log.d("WebSocketConnection", "Game feedback received")
                }
                
                "ping" -> {
                    // Respond to ping
                    val pongMessage = JSONObject().apply {
                        put("type", "pong")
                        put("clientId", clientId)
                    }
                    sendMessage(pongMessage.toString())
                }
                
                "error" -> {
                    val error = json.getString("error")
                    Log.e("WebSocketConnection", "Server error: $error")
                    listener.onError("Server error: $error")
                }
                
                else -> {
                    Log.d("WebSocketConnection", "Unknown message type: $messageType")
                }
            }
            
        } catch (e: Exception) {
            Log.e("WebSocketConnection", "Error processing message: $message", e)
        }
    }
    
    private fun processControlUpdate(json: JSONObject) {
        try {
            val deviceId = json.getString("deviceId")
            val steering = json.getInt("steering")
            val normalizedSteering = json.getDouble("normalizedSteering").toFloat()
            val button = json.getBoolean("button")
            
            Log.d("WebSocketConnection", "Control update - Steering: $steering, Button: $button")
            
            // Notify listeners
            steeringListener?.invoke(normalizedSteering)
            buttonListener?.invoke(button)
            
        } catch (e: Exception) {
            Log.e("WebSocketConnection", "Error processing control update", e)
        }
    }
    
    fun createRoom(roomId: String? = null) {
        val message = JSONObject().apply {
            put("type", "create_room")
            if (roomId != null) {
                put("roomId", roomId)
            }
        }
        
        sendMessage(message.toString())
        Log.d("WebSocketConnection", "Create room request sent")
    }
    
    fun joinRoom(roomId: String) {
        val message = JSONObject().apply {
            put("type", "join_room")
            put("roomId", roomId)
        }
        
        sendMessage(message.toString())
        Log.d("WebSocketConnection", "Join room request sent: $roomId")
    }
    
    fun sendGameCommand(command: String, data: Any? = null) {
        val message = JSONObject().apply {
            put("type", "game_command")
            put("command", command)
            if (data != null) {
                put("data", data)
            }
        }
        
        sendMessage(message.toString())
        Log.d("WebSocketConnection", "Game command sent: $command")
    }
    
    fun sendGameFeedback(gameOver: Boolean = false, lapComplete: Boolean = false) {
        val message = JSONObject().apply {
            put("type", "game_command")
            put("command", "feedback")
            put("data", JSONObject().apply {
                put("gameOver", gameOver)
                put("lapComplete", lapComplete)
            })
        }
        
        sendMessage(message.toString())
    }
    
    private fun sendMessage(message: String) {
        if (!connected || webSocket == null) {
            Log.w("WebSocketConnection", "Cannot send message: not connected")
            return
        }
        
        val success = webSocket?.send(message) ?: false
        if (!success) {
            Log.e("WebSocketConnection", "Failed to send message: $message")
        }
    }
    
    private fun scheduleReconnect() {
        connectionJob?.cancel()
        connectionJob = CoroutineScope(Dispatchers.IO).launch {
            delay(5000) // Wait 5 seconds before reconnecting
            if (!connected) {
                Log.i("WebSocketConnection", "Attempting to reconnect...")
                connect()
            }
        }
    }
    
    fun disconnect() {
        connected = false
        connectionJob?.cancel()
        webSocket?.close(1000, "Client disconnect")
        webSocket = null
        
        Log.i("WebSocketConnection", "Disconnected from server")
    }
    
    fun isConnected(): Boolean = connected
    
    fun getClientId(): String = clientId
    
    companion object {
        const val TAG = "WebSocketConnection"
    }
}

/*
 * Usage Example:
 * 
 * class MainActivity : AppCompatActivity(), WebSocketConnection.WebSocketConnectionListener {
 *     private lateinit var webSocketConnection: WebSocketConnection
 *     
 *     override fun onCreate(savedInstanceState: Bundle?) {
 *         super.onCreate(savedInstanceState)
 *         
 *         webSocketConnection = WebSocketConnection(this, this)
 *         
 *         // Set control listeners
 *         webSocketConnection.setSteeringListener { steering ->
 *             // Update game steering with normalized value (-1 to 1)
 *             updateGameSteering(steering)
 *         }
 *         
 *         webSocketConnection.setButtonListener { pressed ->
 *             // Handle button press (brake, boost, etc.)
 *             handleButtonPress(pressed)
 *         }
 *         
 *         // Connect to server
 *         webSocketConnection.connect()
 *     }
 *     
 *     override fun onConnectionStateChanged(connected: Boolean) {
 *         // Update UI connection status
 *         runOnUiThread {
 *             connectionStatusTextView.text = if (connected) "Connected" else "Disconnected"
 *         }
 *     }
 *     
 *     override fun onDataReceived(data: String) {
 *         // Handle raw data if needed
 *     }
 *     
 *     override fun onError(message: String) {
 *         // Show error to user
 *         runOnUiThread {
 *             Toast.makeText(this, "Error: $message", Toast.LENGTH_SHORT).show()
 *         }
 *     }
 *     
 *     override fun onDeviceConnected(deviceId: String, deviceType: String) {
 *         // Update UI to show connected device
 *     }
 *     
 *     override fun onDeviceDisconnected(deviceId: String) {
 *         // Update UI to show disconnected device
 *     }
 *     
 *     override fun onDestroy() {
 *         super.onDestroy()
 *         webSocketConnection.disconnect()
 *     }
 * }
 */
