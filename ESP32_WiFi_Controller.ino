/*
 * ESP32 Racing Game Controller - WiFi WebSocket Version
 * This code connects to WiFi and sends potentiometer data to a WebSocket server
 * instead of using Bluetooth direct connection.
 */

#include <WiFi.h>
#include <WebSocketsClient.h>
#include <ArduinoJson.h>

// WiFi credentials - CHANGE THESE!
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// WebSocket server configuration
const char* websocket_server = "192.168.1.100";  // Change to your server IP
const int websocket_port = 8080;
const char* websocket_path = "/racing";

// Pin configurations
const int POTENTIOMETER_PIN = A0;  // Analog pin for potentiometer
const int LED_PIN = 2;             // Built-in LED for status indication
const int BUTTON_PIN = 4;          // Optional button for additional controls

// WebSocket client
WebSocketsClient webSocket;

// Variables
int potValue = 0;
int lastPotValue = 0;
unsigned long lastSendTime = 0;
const unsigned long SEND_INTERVAL = 50; // Send every 50ms (20Hz)
bool connected = false;
bool buttonPressed = false;
bool lastButtonState = false;

// Device identification
String deviceId = "ESP32_" + WiFi.macAddress();

void setup() {
  Serial.begin(115200);
  
  // Initialize pins
  pinMode(LED_PIN, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  digitalWrite(LED_PIN, LOW);
  
  Serial.println("ESP32 Racing Controller - WiFi Version");
  Serial.println("=======================================");
  
  // Connect to WiFi
  connectToWiFi();
  
  // Initialize WebSocket connection
  initWebSocket();
  
  Serial.println("ESP32 Racing Controller Ready!");
  Serial.println("Device ID: " + deviceId);
}

void loop() {
  // Handle WebSocket
  webSocket.loop();
  
  // Read controls
  readControls();
  
  // Send data if connected and conditions are met
  if (connected && shouldSendData()) {
    sendControlData();
  }
  
  // Update status LED
  updateStatusLED();
  
  delay(10);
}

void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println();
    Serial.println("WiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("MAC address: ");
    Serial.println(WiFi.macAddress());
  } else {
    Serial.println();
    Serial.println("WiFi connection failed! Check your credentials.");
    // Continue anyway for debugging
  }
}

void initWebSocket() {
  webSocket.begin(websocket_server, websocket_port, websocket_path);
  webSocket.onEvent(webSocketEvent);
  webSocket.setReconnectInterval(5000);
  
  Serial.println("WebSocket client initialized");
  Serial.printf("Connecting to: ws://%s:%d%s\n", websocket_server, websocket_port, websocket_path);
}

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.println("WebSocket Disconnected");
      connected = false;
      break;
      
    case WStype_CONNECTED:
      Serial.printf("WebSocket Connected to: %s\n", payload);
      connected = true;
      
      // Send device registration
      sendDeviceRegistration();
      break;
      
    case WStype_TEXT:
      Serial.printf("Received: %s\n", payload);
      processServerMessage((char*)payload);
      break;
      
    case WStype_ERROR:
      Serial.printf("WebSocket Error: %s\n", payload);
      break;
      
    default:
      break;
  }
}

void readControls() {
  // Read potentiometer
  potValue = analogRead(POTENTIOMETER_PIN);
  
  // Read button
  buttonPressed = !digitalRead(BUTTON_PIN); // Inverted because of pull-up
}

bool shouldSendData() {
  unsigned long currentTime = millis();
  
  if (currentTime - lastSendTime < SEND_INTERVAL) {
    return false;
  }
  
  // Send if potentiometer value changed significantly
  int potDifference = abs(potValue - lastPotValue);
  bool potChanged = potDifference > 15; // Reduced sensitivity for network
  
  // Send if button state changed
  bool buttonChanged = buttonPressed != lastButtonState;
  
  // Force send every 200ms even if no change (heartbeat)
  bool heartbeat = (currentTime - lastSendTime >= 200);
  
  return potChanged || buttonChanged || heartbeat;
}

void sendControlData() {
  // Create JSON message
  DynamicJsonDocument doc(256);
  doc["type"] = "control_data";
  doc["deviceId"] = deviceId;
  doc["timestamp"] = millis();
  doc["steering"] = potValue;
  doc["button"] = buttonPressed;
  
  // Convert to normalized values for game
  float normalizedSteering = (potValue / 1023.0) * 2.0 - 1.0; // -1 to 1
  doc["normalizedSteering"] = normalizedSteering;
  
  String message;
  serializeJson(doc, message);
  
  // Send via WebSocket
  webSocket.sendTXT(message);
  
  // Debug output
  Serial.printf("Sent: %s\n", message.c_str());
  
  // Update last values
  lastPotValue = potValue;
  lastButtonState = buttonPressed;
  lastSendTime = millis();
}

void sendDeviceRegistration() {
  DynamicJsonDocument doc(256);
  doc["type"] = "device_registration";
  doc["deviceId"] = deviceId;
  doc["deviceType"] = "ESP32_Racing_Controller";
  doc["capabilities"] = "steering,button";
  doc["version"] = "2.0";
  
  String message;
  serializeJson(doc, message);
  
  webSocket.sendTXT(message);
  Serial.printf("Device registered: %s\n", message.c_str());
}

void processServerMessage(const char* message) {
  DynamicJsonDocument doc(512);
  DeserializationError error = deserializeJson(doc, message);
  
  if (error) {
    Serial.printf("JSON parse error: %s\n", error.c_str());
    return;
  }
  
  String messageType = doc["type"];
  
  if (messageType == "game_feedback") {
    // Handle game feedback (vibration, LEDs, etc.)
    if (doc["gameOver"]) {
      flashGameOverLED();
    }
    
    if (doc["lapComplete"]) {
      flashSuccessLED();
    }
    
  } else if (messageType == "server_config") {
    // Handle server configuration updates
    if (doc.containsKey("sendInterval")) {
      // Update send interval if needed
    }
    
  } else if (messageType == "ping") {
    // Respond to ping
    DynamicJsonDocument pong(128);
    pong["type"] = "pong";
    pong["deviceId"] = deviceId;
    
    String response;
    serializeJson(pong, response);
    webSocket.sendTXT(response);
  }
}

void updateStatusLED() {
  static unsigned long lastBlink = 0;
  static bool ledState = false;
  
  unsigned long currentTime = millis();
  
  if (connected) {
    // Slow blink when connected
    if (currentTime - lastBlink >= 1000) {
      ledState = !ledState;
      digitalWrite(LED_PIN, ledState);
      lastBlink = currentTime;
    }
  } else {
    // Fast blink when disconnected
    if (currentTime - lastBlink >= 200) {
      ledState = !ledState;
      digitalWrite(LED_PIN, ledState);
      lastBlink = currentTime;
    }
  }
}

void flashGameOverLED() {
  for (int i = 0; i < 10; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(50);
    digitalWrite(LED_PIN, LOW);
    delay(50);
  }
}

void flashSuccessLED() {
  for (int i = 0; i < 3; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(200);
    digitalWrite(LED_PIN, LOW);
    delay(100);
  }
}

/*
 * Installation Instructions:
 * 
 * 1. Install required libraries in Arduino IDE:
 *    - ArduinoJson by Benoit Blanchon
 *    - WebSockets by Markus Sattler
 * 
 * 2. Update WiFi credentials:
 *    - Change ssid and password variables
 *    - Change websocket_server to your server IP
 * 
 * 3. Wiring (same as Bluetooth version):
 *    - Potentiometer VCC to 3.3V
 *    - Potentiometer Signal to GPIO36 (A0)
 *    - Potentiometer GND to GND
 *    - Optional: Button between GPIO4 and GND
 * 
 * 4. Create a WebSocket server to receive the data
 *    (see server examples in project)
 * 
 * Message Format (JSON):
 * {
 *   "type": "control_data",
 *   "deviceId": "ESP32_XX:XX:XX:XX:XX:XX",
 *   "timestamp": 12345,
 *   "steering": 512,
 *   "button": false,
 *   "normalizedSteering": 0.0
 * }
 */
