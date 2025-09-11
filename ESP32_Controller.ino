/*
 * ESP32 Racing Game Controller
 * This code reads a potentiometer value and sends it via Bluetooth
 * to the Android racing game for steering control.
 */

#include "BluetoothSerial.h"

BluetoothSerial SerialBT;

// Pin configurations
const int POTENTIOMETER_PIN = A0;  // Analog pin for potentiometer
const int LED_PIN = 2;             // Built-in LED for status indication

// Variables
int potValue = 0;
int lastPotValue = 0;
unsigned long lastSendTime = 0;
const unsigned long SEND_INTERVAL = 50; // Send every 50ms (20Hz)

void setup() {
  Serial.begin(115200);
  
  // Initialize Bluetooth
  SerialBT.begin("ESP32-Racing"); // Bluetooth device name
  Serial.println("The device started, now you can pair it with bluetooth!");
  
  // Initialize pins
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  
  Serial.println("ESP32 Racing Controller Ready!");
  Serial.println("Connect potentiometer:");
  Serial.println("- VCC to 3.3V");
  Serial.println("- GND to GND");
  Serial.println("- Signal to pin A0 (GPIO36)");
}

void loop() {
  // Read potentiometer value
  potValue = analogRead(POTENTIOMETER_PIN);
  
  // Send data if enough time has passed and value has changed significantly
  unsigned long currentTime = millis();
  if (currentTime - lastSendTime >= SEND_INTERVAL) {
    int difference = abs(potValue - lastPotValue);
    
    // Send if value changed by more than 10 to reduce noise
    if (difference > 10 || (currentTime - lastSendTime >= 200)) {
      // Send potentiometer value via Bluetooth
      String data = "POT:" + String(potValue);
      SerialBT.println(data);
      
      // Also send to serial monitor for debugging
      Serial.println("Sent: " + data + " (Raw: " + String(potValue) + ")");
      
      // Update LED to show activity
      digitalWrite(LED_PIN, !digitalRead(LED_PIN));
      
      lastPotValue = potValue;
      lastSendTime = currentTime;
    }
  }
  
  // Check for incoming Bluetooth data (for future expansion)
  if (SerialBT.available()) {
    String receivedData = SerialBT.readString();
    receivedData.trim();
    Serial.println("Received: " + receivedData);
    
    // You can add game feedback here (like vibration, LEDs, etc.)
    if (receivedData == "GAME_OVER") {
      // Flash LED rapidly for game over
      for (int i = 0; i < 10; i++) {
        digitalWrite(LED_PIN, HIGH);
        delay(50);
        digitalWrite(LED_PIN, LOW);
        delay(50);
      }
    }
  }
  
  // Small delay to prevent overwhelming the system
  delay(10);
}

/*
 * Wiring Instructions:
 * 
 * Potentiometer:
 * - Left pin (or VCC): Connect to 3.3V
 * - Middle pin (Signal): Connect to GPIO36 (A0)
 * - Right pin (or GND): Connect to GND
 * 
 * Optional additions:
 * - LED on GPIO2 (built-in) shows Bluetooth activity
 * - You can add more controls like buttons for additional game features
 * 
 * Pairing Instructions:
 * 1. Upload this code to ESP32
 * 2. Open Serial Monitor to see status messages
 * 3. On Android device, enable Bluetooth and pair with "ESP32-Racing"
 * 4. Open the racing game app and click "Connect ESP32"
 * 5. Turn the potentiometer to control the car steering
 * 
 * Potentiometer values:
 * - 0: Full left steering
 * - 512: Center (no steering)
 * - 1023: Full right steering
 */