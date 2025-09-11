# Need For Control - ESP32 Racing Game

Este repositorio es un juego de carreras para Android controlado por ESP32 usando un potenciómetro para el control del volante.

## Características

- 🏎️ Juego de carreras 2D en Android
- 🎮 Control por ESP32 con potenciómetro via Bluetooth
- 📱 Interfaz simple y fácil de usar
- 🏁 Sistema de puntuación
- 🚧 Detección de colisiones
- 📡 Comunicación Bluetooth en tiempo real

## Requisitos de Hardware

### ESP32
- Microcontrolador ESP32
- Potenciómetro de 10kΩ
- Cables de conexión
- Protoboard (opcional)

### Android
- Dispositivo Android con API 21+ (Android 5.0)
- Bluetooth habilitado
- Pantalla en orientación horizontal recomendada

## Instalación y Configuración

### 1. Configuración del ESP32

#### Conexiones del Potenciómetro:
```
Potenciómetro → ESP32
VCC (3.3V)   → Pin 3.3V
GND          → Pin GND  
Signal       → Pin GPIO36 (A0)
```

#### Código ESP32:
1. Abre Arduino IDE
2. Instala la librería ESP32 si no la tienes
3. Abre el archivo `ESP32_Controller.ino`
4. Sube el código al ESP32
5. Abre el Monitor Serie para ver el estado

### 2. Configuración Android

#### Para compilar desde código fuente:
```bash
# Clona el repositorio
git clone https://github.com/ivan22102000/need_for_control.git
cd need_for_control

# Abre en Android Studio y compila
# O usa gradle (requiere Android SDK):
./gradlew assembleDebug
```

### 3. Uso del Sistema

1. **Preparar ESP32:**
   - Conecta el potenciómetro según el diagrama
   - Enciende el ESP32
   - Verifica que aparezca "ESP32-Racing" en dispositivos Bluetooth

2. **Configurar Android:**
   - Habilita Bluetooth en el dispositivo
   - Empareja con "ESP32-Racing"
   - Abre la aplicación "Need For Control"

3. **Jugar:**
   - Presiona "Connect ESP32" en la app
   - Espera a que diga "Connected"
   - Gira el potenciómetro para controlar el auto
   - ¡Evita los obstáculos y consigue la mayor puntuación!

## Controles

- **Potenciómetro Izquierda:** Gira el auto hacia la izquierda
- **Potenciómetro Centro:** Auto va recto
- **Potenciómetro Derecha:** Gira el auto hacia la derecha

## Estructura del Proyecto

```
need_for_control/
├── app/                          # Aplicación Android
│   ├── src/main/java/com/needforcontrol/racing/
│   │   ├── MainActivity.kt       # Actividad principal
│   │   ├── GameView.kt          # Vista del juego
│   │   └── BluetoothConnection.kt # Conexión Bluetooth
│   └── src/main/res/            # Recursos Android
├── ESP32_Controller.ino         # Código Arduino para ESP32
└── README.md                    # Este archivo
```

## Protocolo de Comunicación

El ESP32 envía datos en formato:
```
POT:XXX
```
Donde XXX es un valor de 0-1023 del potenciómetro.

## Solución de Problemas

### Conexión Bluetooth
- Verifica que el Bluetooth esté habilitado
- Asegúrate de que el ESP32 esté emparejado
- Reinicia la aplicación si la conexión falla

### Juego no responde
- Verifica la conexión Bluetooth
- Comprueba que el potenciómetro esté conectado correctamente
- Revisa el Monitor Serie del ESP32 para mensajes de debug

### Rendimiento
- Cierra otras aplicaciones Bluetooth
- Mantén el ESP32 cerca del dispositivo Android

## Expansiones Futuras

- Múltiples niveles de dificultad
- Efectos de sonido
- Vibración del dispositivo
- Controles adicionales (botones, acelerómetro)
- Modo multijugador

## Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Haz fork del repositorio
2. Crea una rama para tu característica
3. Haz commit de tus cambios
4. Envía un pull request

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo LICENSE para más detalles.

## Autor

Desarrollado para el control de juegos mediante ESP32 y Android.
