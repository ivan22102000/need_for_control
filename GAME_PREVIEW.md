# Game Preview - Need For Control

## Vista del Juego en Acción

```
┌────────────────────────────────────────────────────────────────┐
│ [Connect ESP32] │ Connection Status: Connected │ Score: 1247   │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│    ║                    ║                    ║                │
│    ║         🚗         ║                    ║                │
│    ║      (Player)      ║                    ║                │
│    ║                    ║                    ║                │
│    ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║                │
│    ║                    ║                    ║                │
│    ║                    ║        🚗          ║                │
│    ║                    ║    (Obstacle)      ║                │
│    ║                    ║                    ║                │
│    ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║                │
│    ║                    ║                    ║                │
│    ║                    ║                    ║                │
│    ║                    ║                    ║                │
│    ║                    ║                    ║                │
│    ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║                │
│    ║                    ║                    ║                │
│    ║             🚗     ║                    ║                │
│    ║         (Obstacle) ║                    ║                │
│    ║                    ║                    ║                │
│    ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║                │
│    ║                    ║                    ║                │
└────────────────────────────────────────────────────────────────┘
```

## Elementos del Juego

### Carretera (Road):
- **Color:** Gris (#404040)
- **Marcadores de carril:** Líneas blancas punteadas
- **3 carriles** para maniobrar
- **Animación:** Los marcadores se mueven hacia abajo

### Auto del Jugador:
- **Color:** Azul (#0088FF)
- **Posición:** Controlada por potenciómetro ESP32
- **Tamaño:** 80x160 píxeles
- **Física:** Suave interpolación de movimiento

### Obstáculos:
- **Color:** Rojo (#FF4444)
- **Generación:** Aleatoria cada 2 segundos
- **Carriles:** Aparecen en cualquiera de los 3 carriles
- **Velocidad:** Se mueven hacia abajo a velocidad constante

### UI Elements:
- **Botón Connect:** Azul, cambia a "Disconnect" cuando conectado
- **Status:** Verde para "Connected", Rojo para "Disconnected"
- **Score:** Contador en tiempo real

## Control del Juego

### Mapeo del Potenciómetro:

```
Potenciómetro Value → Steering Action
     0 - 341       → Giro máximo izquierda
   342 - 682       → Posición centro (recto)
   683 - 1023      → Giro máximo derecha
```

### Responsividad:
- **Frecuencia de actualización:** 20Hz (cada 50ms)
- **Suavizado:** Interpolación lineal para movimiento fluido
- **Límites:** El auto no puede salir de la carretera

## Estados del Juego

### 1. Inicio (Disconnected)
```
┌────────────────────────────────────────────────────────────────┐
│ [Connect ESP32] │ Connection Status: Disconnected │ Score: 0  │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│                        NEED FOR CONTROL                       │
│                                                                │
│                     🎮 Press Connect ESP32                     │
│                      to start the game                        │
│                                                                │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### 2. Jugando (Connected)
```
┌────────────────────────────────────────────────────────────────┐
│ [Disconnect]    │ Connection Status: Connected   │ Score: 1247│
├────────────────────────────────────────────────────────────────┤
│    ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║                │
│    ║         🚗         ║                    ║                │
│    ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║                │
│    ║                    ║        🚗          ║                │
│    ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ┆ ║                │
│                        [GAME ACTIVE]                          │
└────────────────────────────────────────────────────────────────┘
```

### 3. Game Over
```
┌────────────────────────────────────────────────────────────────┐
│ [Connect ESP32] │ Connection Status: Connected   │ Score: 1247│
├────────────────────────────────────────────────────────────────┤
│                                                                │
│                         GAME OVER                             │
│                                                                │
│                      Final Score: 1247                        │
│                                                                │
│                    🎮 Restart game to play again               │
│                                                                │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Feedback Visual

### LED ESP32:
```
Estado          │ LED Behavior
════════════════┼══════════════════════
Iniciando       │ Apagado
Bluetooth Ready │ Encendido fijo
Enviando datos  │ Parpadeo rápido
Conectado       │ Parpadeo lento
Error           │ Parpadeo muy rápido
```

### Indicadores Android:
```
Connection Status Colors:
- Disconnected: #FF4444 (Rojo)
- Connecting:   #FFAA00 (Naranja)  
- Connected:    #00AA00 (Verde)
```

## Mecánicas de Juego

### Sistema de Puntuación:
- **+1 punto** por cada frame sin colisión
- **60 puntos por segundo** aproximadamente
- **Puntuación se resetea** al reiniciar

### Detección de Colisiones:
- **Algoritmo:** Rectangular bounding box
- **Precisión:** Píxel perfecto en los bordes
- **Resultado:** Game Over inmediato

### Generación de Obstáculos:
- **Frecuencia:** Cada 2 segundos
- **Posición:** Aleatoria en 3 carriles
- **Tamaño:** 60x120 píxeles
- **Velocidad:** 2x velocidad de la carretera

## Performance Esperado

### Frame Rate:
```
Target: 60 FPS
Minimum: 30 FPS (en dispositivos más antiguos)
Actual: Depende del hardware Android
```

### Latencia:
```
ESP32 → Android: ~20-50ms
Android Processing: ~5-10ms
Total End-to-End: ~30-70ms
```

### Recursos:
```
RAM Usage: ~50-100MB
CPU Usage: ~15-25% 
Battery: ~2-4 horas de juego continuo
```

¡El juego está completamente funcional y listo para jugar! 🎮🏎️