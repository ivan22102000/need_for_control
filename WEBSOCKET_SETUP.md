# 🏎️ Need for Control - WebSocket Server Setup

## Descripción

Sistema de control para juegos de carreras usando ESP32 y aplicación Android, comunicándose a través de un servidor WebSocket.

## Arquitectura

```
[ESP32 Controller] --WiFi--> [WebSocket Server] <--WiFi--> [Android App]
```

### Ventajas del servidor WebSocket:
- ✅ Múltiples dispositivos ESP32 simultáneos
- ✅ Múltiples jugadores (multijugador)
- ✅ Conexión remota (no solo local)
- ✅ Salas de juego (rooms)
- ✅ Escalabilidad
- ✅ Interfaz web de pruebas

## 📦 Instalación y Configuración

### 1. Servidor WebSocket (Node.js)

```bash
# Navegar a la carpeta del servidor
cd server

# Instalar dependencias
npm install

# Iniciar servidor
npm start
```

El servidor estará disponible en:
- **WebSocket**: `ws://localhost:8080/racing`
- **Interfaz web**: `http://localhost:8080`

### 2. ESP32 Controller

#### Librerías requeridas (Arduino IDE):
```
- ArduinoJson by Benoit Blanchon
- WebSockets by Markus Sattler
```

#### Configuración en `ESP32_WiFi_Controller.ino`:
```cpp
// Cambiar estas credenciales:
const char* ssid = "TU_WIFI_SSID";
const char* password = "TU_WIFI_PASSWORD";
const char* websocket_server = "192.168.1.100";  // IP de tu servidor
```

#### Cableado:
```
Potenciometer:
- VCC  → 3.3V
- Signal → GPIO36 (A0)
- GND  → GND

Button (opcional):
- GPIO4 → Button → GND
```

### 3. Aplicación Android

#### Dependencias requeridas en `build.gradle`:
```gradle
implementation 'com.squareup.okhttp3:okhttp:4.11.0'
implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
```

#### Configuración en `WebSocketConnection.kt`:
```kotlin
// Cambiar esta URL:
private val serverUrl = "ws://192.168.1.100:8080/racing"
```

## 🚀 Uso

### Paso 1: Iniciar el servidor
```bash
cd server
npm start
```

### Paso 2: Conectar ESP32
1. Subir código a ESP32
2. Abrir Serial Monitor
3. Verificar conexión WiFi y WebSocket

### Paso 3: Conectar aplicación Android
1. Compilar e instalar app
2. Verificar conexión al servidor
3. Los controles del ESP32 aparecerán automáticamente

### Paso 4: Probar en interfaz web
1. Abrir `http://localhost:8080`
2. Hacer clic en "Connect to Server"
3. Ver datos del ESP32 en tiempo real

## 📋 Protocolo de Mensajes

### ESP32 → Servidor
```json
{
  "type": "control_data",
  "deviceId": "ESP32_XX:XX:XX:XX:XX:XX",
  "steering": 512,
  "normalizedSteering": 0.0,
  "button": false,
  "timestamp": 12345
}
```

### Android ↔ Servidor
```json
// Registro
{
  "type": "client_registration",
  "clientId": "android_12345",
  "clientType": "android_app",
  "playerName": "Player 1"
}

// Crear sala
{
  "type": "create_room"
}

// Feedback al ESP32
{
  "type": "game_command",
  "command": "feedback",
  "data": {
    "gameOver": true,
    "lapComplete": false
  }
}
```

## 🔧 Configuración de Red

### Encontrar la IP del servidor:
```bash
# Windows
ipconfig

# Linux/Mac
ifconfig
```

### Configurar firewall (Windows):
```bash
# Permitir puerto 8080
netsh advfirewall firewall add rule name="Racing Game Server" dir=in action=allow protocol=TCP localport=8080
```

## 🎮 Características del Juego

### Controles ESP32:
- **Potenciómetro**: Dirección (-1.0 a 1.0)
- **Botón**: Freno/Boost/Acción

### Salas multijugador:
- Múltiples jugadores por sala
- Múltiples dispositivos ESP32 por sala
- Sincronización en tiempo real

### Feedback al ESP32:
- LED de estado de conexión
- Efectos al terminar carrera
- Efectos al completar vuelta

## 📊 Monitoreo

### Interfaz web (localhost:8080):
- Estado de conexiones
- Datos de control en tiempo real
- Lista de dispositivos conectados
- Salas de juego activas
- Log de mensajes

### API REST:
- `GET /api/devices` - Dispositivos conectados
- `GET /api/rooms` - Salas activas

## 🛠️ Desarrollo

### Scripts disponibles:
```bash
npm start       # Iniciar servidor
npm run dev     # Desarrollo con nodemon
npm test        # Ejecutar tests
```

### Estructura del proyecto:
```
server/
├── websocket-server.js     # Servidor principal
├── package.json           # Dependencias
└── public/
    └── index.html        # Interfaz de prueba

ESP32_WiFi_Controller.ino  # Código ESP32
WebSocketConnection.kt     # Cliente Android
```

## 🔍 Solución de Problemas

### ESP32 no se conecta:
1. Verificar credenciales WiFi
2. Verificar IP del servidor
3. Revisar Serial Monitor
4. Comprobar firewall

### Android no recibe datos:
1. Verificar URL del servidor
2. Verificar conexión de red
3. Revisar logs (Logcat)
4. Verificar permisos de red

### Servidor no inicia:
1. Verificar Node.js instalado
2. Ejecutar `npm install`
3. Verificar puerto 8080 libre
4. Revisar permisos de firewall

## 📝 TODO / Mejoras Futuras

- [ ] Autenticación de usuarios
- [ ] Persistencia de salas
- [ ] Métricas de latencia
- [ ] Modo torneo
- [ ] Grabación de carreras
- [ ] Soporte para más sensores
- [ ] Dashboard de administración
- [ ] Notificaciones push

---

¡Disfruta tu sistema de control para carreras! 🏁
