# Diagrama de Conexiones - Need For Control

## Esquema de Conexiones ESP32 + Potenciómetro

```
                    ESP32 DevKit v1
                    ┌─────────────────┐
                    │                 │
               3.3V │●               ●│ GND
                    │                 │
                    │                 │
                    │                 │
                    │                 │
                    │                 │
                    │                 │
                    │                 │
                    │                 │
                    │                 │
             GPIO36 │●               ●│
               (A0) │                 │
                    │                 │
                    │                 │
                    │         ●GPIO2  │ LED integrado
                    │      (LED)      │
                    └─────────────────┘
                             ▲
                             │ USB para programación
                             │


        Potenciómetro 10kΩ
        ┌─────────────────┐
        │    ┌─────┐      │
        │ ●──┤     ├──●   │ Terminal 1 (VCC) → 3.3V ESP32
        │    │  ^  │      │ Terminal 2 (OUT) → GPIO36 ESP32  
        │    │  │  │      │ Terminal 3 (GND) → GND ESP32
        │    │     │      │
        │    └─────┘      │
        └─────────────────┘
              Perilla
```

## Conexiones Detalladas

| Componente | Pin/Terminal | ESP32 Pin | Color Cable (sugerido) |
|------------|--------------|-----------|------------------------|
| Potenciómetro | VCC (Terminal 1) | 3.3V | Rojo |
| Potenciómetro | Signal (Terminal 2) | GPIO36 (A0) | Amarillo |
| Potenciómetro | GND (Terminal 3) | GND | Negro |
| LED Integrado | - | GPIO2 | - |

## Vista de Protoboard (Opcional)

```
Protoboard:
    a  b  c  d  e     f  g  h  i  j
1   ●  ●  ●  ●  ●     ●  ●  ●  ●  ●
2   ●  ●  ●  ●  ●     ●  ●  ●  ●  ●
3   ●  ●  ●  ●  ●     ●  ●  ●  ●  ●
4   ●  ●  ●  ●  ●     ●  ●  ●  ●  ●
5   ●  ●  ●  ●  ●     ●  ●  ●  ●  ●

Conexiones en protoboard:
- Fila 1: 3.3V ESP32 → a1, Potenciómetro Terminal 1 → e1
- Fila 2: GPIO36 ESP32 → a2, Potenciómetro Terminal 2 → e2  
- Fila 3: GND ESP32 → a3, Potenciómetro Terminal 3 → e3
```

## Verificación de Conexiones

### Checklist de Verificación:

- [ ] **Alimentación:**
  - 3.3V ESP32 conectado a Terminal 1 del potenciómetro
  - GND ESP32 conectado a Terminal 3 del potenciómetro

- [ ] **Señal:**
  - GPIO36 (A0) ESP32 conectado a Terminal 2 del potenciómetro
  - No hay cortocircuitos entre pines

- [ ] **Físico:**
  - Todas las conexiones están firmes
  - Potenciómetro puede girar libremente
  - ESP32 está conectado por USB para programación

### Prueba de Funcionamiento:

1. **Test de Alimentación:**
   ```cpp
   // En Arduino IDE, Monitor Serie debe mostrar:
   Serial.begin(115200);
   Serial.println("ESP32 iniciado correctamente");
   ```

2. **Test de Potenciómetro:**
   ```cpp
   // Los valores deben cambiar al girar el potenciómetro:
   int valor = analogRead(A0);
   Serial.println(valor); // Debe variar entre 0-1023
   ```

3. **Test de Bluetooth:**
   ```cpp
   // Debe aparecer en dispositivos Bluetooth como "ESP32-Racing"
   SerialBT.begin("ESP32-Racing");
   ```

## Solución de Problemas de Hardware

### Problema: Valores del potenciómetro no cambian
```
Causa posible: Mala conexión en Terminal 2
Solución: Verificar conexión GPIO36 ↔ Terminal central
```

### Problema: Valores erráticos o ruidosos
```
Causa posible: Conexiones flojas o potenciómetro defectuoso
Solución: 
1. Verificar todas las conexiones
2. Agregar capacitor de 0.1µF entre señal y GND (opcional)
3. Probar con otro potenciómetro
```

### Problema: ESP32 no enciende
```
Causa posible: Problema de alimentación
Solución:
1. Verificar cable USB
2. Probar con otro puerto USB
3. Verificar que no hay cortocircuitos
```

### Problema: No aparece en Bluetooth
```
Causa posible: Código no cargado o error en programación
Solución:
1. Re-subir el código ESP32_Controller.ino
2. Verificar selección de placa ESP32 Dev Module
3. Resetear ESP32 después de programar
```

## Expansiones de Hardware

### Agregar Botones (Opcional):
```
Botón 1 (Acelerador):
GPIO4 → Un terminal del botón
GND → Otro terminal del botón

Botón 2 (Freno):
GPIO5 → Un terminal del botón
GND → Otro terminal del botón
```

### Agregar LEDs de Estado (Opcional):
```
LED Conectado:
GPIO12 → Resistencia 220Ω → LED Ánodo
GND → LED Cátodo

LED Game Over:
GPIO13 → Resistencia 220Ω → LED Ánodo
GND → LED Cátodo
```

### Vibrador para Feedback (Opcional):
```
Motor Vibrador:
GPIO14 → Terminal positivo del motor
GND → Terminal negativo del motor
Nota: Usar transistor si el motor consume >20mA
```

## Consideraciones de Seguridad

- ⚠️ **Nunca exceder 3.3V en los pines GPIO del ESP32**
- ⚠️ **Verificar polaridad antes de conectar alimentación**
- ⚠️ **Desconectar alimentación antes de modificar conexiones**
- ⚠️ **Usar resistencias apropiadas para LEDs adicionales**

## Herramientas Recomendadas

- Multímetro para verificar continuidad
- Alicates para cables
- Destornilladores pequeños
- Protoboard y cables jumper de calidad
- Cinta aislante para conexiones temporales