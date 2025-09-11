# Setup Guide - Need For Control

## Guía de Instalación Completa

### 1. Preparación del ESP32

#### Materiales Necesarios:
- 1x ESP32 DevKit
- 1x Potenciómetro 10kΩ
- 3x Cables jumper macho-macho
- 1x Protoboard (opcional)

#### Software Requerido:
- Arduino IDE (versión 1.8.19 o superior)
- ESP32 Board Package para Arduino

#### Instalación del Software:

1. **Instalar Arduino IDE:**
   - Descarga desde: https://www.arduino.cc/en/software
   - Instala siguiendo las instrucciones de tu sistema operativo

2. **Configurar ESP32 en Arduino IDE:**
   ```
   File → Preferences → Additional Board Manager URLs:
   https://dl.espressif.com/dl/package_esp32_index.json
   
   Tools → Board → Board Manager → Buscar "ESP32" → Install
   ```

3. **Instalar Librerías:**
   - La librería BluetoothSerial ya viene incluida con ESP32

#### Conexiones del Hardware:

```
Potenciómetro    →    ESP32
Terminal 1 (VCC) →    3.3V
Terminal 2 (OUT) →    GPIO36 (A0)
Terminal 3 (GND) →    GND
```

#### Programación del ESP32:

1. Conecta el ESP32 a tu computadora via USB
2. Abre `ESP32_Controller.ino` en Arduino IDE
3. Selecciona la placa: `Tools → Board → ESP32 Dev Module`
4. Selecciona el puerto correcto: `Tools → Port → COMx` (Windows) o `/dev/ttyUSBx` (Linux)
5. Presiona Upload (Ctrl+U)
6. Abre el Monitor Serie (Ctrl+Shift+M) para ver el estado

### 2. Preparación de Android

#### Opción A: Instalación desde APK (Recomendado)
1. Descarga el APK desde las releases del repositorio
2. Habilita "Fuentes desconocidas" en configuración de Android
3. Instala el APK

#### Opción B: Compilación desde Código Fuente

**Requisitos:**
- Android Studio 4.2 o superior
- Android SDK API 21-34
- JDK 8 o superior

**Pasos:**
1. Clona el repositorio:
   ```bash
   git clone https://github.com/ivan22102000/need_for_control.git
   ```

2. Abre el proyecto en Android Studio:
   - File → Open → Selecciona la carpeta del proyecto
   - Espera a que se sincronizen las dependencias

3. Conecta tu dispositivo Android o configura un emulador

4. Ejecuta la aplicación:
   - Run → Run 'app' (Shift+F10)

### 3. Configuración del Sistema

#### Configuración ESP32:
1. Enciende el ESP32
2. Verifica en el Monitor Serie que aparezca:
   ```
   The device started, now you can pair it with bluetooth!
   ESP32 Racing Controller Ready!
   ```

#### Configuración Android:
1. Ve a Configuración → Bluetooth
2. Busca dispositivos disponibles
3. Conecta con "ESP32-Racing"
4. Introduce PIN si se solicita (usualmente 1234 o 0000)

#### Primera Conexión:
1. Abre la aplicación "Need For Control"
2. Presiona "Connect ESP32"
3. Espera a que el estado cambie a "Connected"
4. El LED del ESP32 debería parpadear indicando actividad

### 4. Uso del Juego

#### Controles:
- **Potenciómetro Izquierda (0-400):** Gira el auto hacia la izquierda
- **Potenciómetro Centro (400-600):** Auto va recto
- **Potenciómetro Derecha (600-1023):** Gira el auto hacia la derecha

#### Objetivo:
- Evita los obstáculos rojos
- Mantente en la carretera
- Consigue la mayor puntuación posible

#### Indicadores:
- **Connection Status:** Muestra el estado de la conexión Bluetooth
- **Score:** Puntuación actual del juego
- LED ESP32 parpadea cuando envía datos

### 5. Solución de Problemas

#### Problemas de Conexión ESP32:
```
Problema: No aparece "ESP32-Racing" en Bluetooth
Solución: 
- Verifica que el código esté cargado correctamente
- Resetea el ESP32
- Revisa las conexiones del potenciómetro
```

```
Problema: Conexión se desconecta frecuentemente
Solución:
- Mantén el ESP32 cerca del dispositivo Android (máximo 10 metros)
- Evita interferencias de otros dispositivos Bluetooth
- Verifica que la batería del ESP32 esté bien
```

#### Problemas Android:
```
Problema: La aplicación no se conecta
Solución:
- Verifica que el Bluetooth esté habilitado
- Confirma que "ESP32-Racing" esté emparejado
- Reinicia la aplicación
- Desempareja y vuelve a emparejar el dispositivo
```

```
Problema: El auto no responde al potenciómetro
Solución:
- Verifica la conexión en "Connection Status"
- Revisa el Monitor Serie del ESP32 para ver si envía datos
- Prueba girar el potenciómetro completamente en ambas direcciones
```

#### Problemas de Rendimiento:
```
Problema: El juego va lento
Solución:
- Cierra otras aplicaciones en segundo plano
- Reduce la calidad gráfica si es configurable
- Reinicia el dispositivo Android
```

### 6. Personalización Avanzada

#### Modificar Sensibilidad del Control:
En `ESP32_Controller.ino`, línea 31:
```cpp
const unsigned long SEND_INTERVAL = 50; // Cambiar a 30 para mayor frecuencia
```

En `BluetoothConnection.kt`, función `processReceivedData`:
```kotlin
// Ajustar la conversión del potenciómetro
val normalizedValue = value.coerceIn(0f, 1023f)
```

#### Agregar Controles Adicionales:
1. Conecta botones a otros pines GPIO del ESP32
2. Modifica el código para leer botones adicionales
3. Envía comandos específicos ("BRAKE", "TURBO", etc.)
4. Actualiza la aplicación Android para manejar nuevos comandos

### 7. Mantenimiento

#### Cuidado del Hardware:
- Evita cortocircuitos al conectar componentes
- Desconecta la alimentación antes de modificar conexiones
- Mantén los componentes secos y limpios

#### Actualizaciones de Software:
- Revisa regularmente el repositorio para nuevas versiones
- Actualiza Arduino IDE y librerías periódicamente
- Mantén Android Studio actualizado para desarrollo

### 8. Soporte y Comunidad

Para obtener ayuda adicional:
- Crea un issue en el repositorio de GitHub
- Revisa la documentación en el README.md
- Consulta el código fuente para entender el funcionamiento

¡Disfruta tu juego de carreras controlado por ESP32!