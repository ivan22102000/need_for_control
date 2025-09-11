package com.needforcontrol.racing

import android.app.Activity
import android.bluetooth.*
import android.content.Context
import android.content.Intent
import android.util.Log
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.*

class BluetoothConnection(
    private val context: Context,
    private val listener: BluetoothConnectionListener
) {
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var bluetoothSocket: BluetoothSocket? = null
    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var readThread: Thread? = null
    private var connected = false
    
    // ESP32 Bluetooth UUID (standard Serial Port Profile)
    private val SPP_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB")
    
    // ESP32 device name or address (you can modify this)
    private val ESP32_NAME = "ESP32-Racing"
    
    private var steeringListener: ((Float) -> Unit)? = null
    
    interface BluetoothConnectionListener {
        fun onConnectionStateChanged(connected: Boolean)
        fun onDataReceived(data: String)
        fun onError(message: String)
    }
    
    init {
        bluetoothAdapter = BluetoothAdapter.getDefaultAdapter()
        
        if (bluetoothAdapter == null) {
            listener.onError("Bluetooth not supported on this device")
        } else if (!bluetoothAdapter!!.isEnabled) {
            val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            (context as Activity).startActivityForResult(enableBtIntent, 1)
        }
    }
    
    fun setSteeringListener(listener: (Float) -> Unit) {
        steeringListener = listener
    }
    
    fun connect() {
        if (bluetoothAdapter == null || !bluetoothAdapter!!.isEnabled) {
            listener.onError("Bluetooth is not enabled")
            return
        }
        
        Thread {
            try {
                // Find ESP32 device
                val device = findESP32Device()
                if (device == null) {
                    listener.onError("ESP32 device not found. Make sure it's paired and discoverable.")
                    return@Thread
                }
                
                // Create socket
                bluetoothSocket = device.createRfcommSocketToServiceRecord(SPP_UUID)
                
                // Cancel discovery to speed up connection
                bluetoothAdapter!!.cancelDiscovery()
                
                // Connect
                bluetoothSocket!!.connect()
                
                // Get streams
                inputStream = bluetoothSocket!!.inputStream
                outputStream = bluetoothSocket!!.outputStream
                
                connected = true
                listener.onConnectionStateChanged(true)
                
                // Start reading data
                startReadThread()
                
            } catch (e: IOException) {
                Log.e("BluetoothConnection", "Connection failed", e)
                listener.onError("Connection failed: ${e.message}")
                disconnect()
            } catch (e: SecurityException) {
                Log.e("BluetoothConnection", "Permission denied", e)
                listener.onError("Bluetooth permission denied")
            }
        }.start()
    }
    
    private fun findESP32Device(): BluetoothDevice? {
        try {
            val pairedDevices = bluetoothAdapter!!.bondedDevices
            
            // Look for device by name
            for (device in pairedDevices) {
                if (device.name?.contains("ESP32", ignoreCase = true) == true ||
                    device.name?.contains(ESP32_NAME, ignoreCase = true) == true) {
                    return device
                }
            }
            
            // If not found by name, return the first paired device
            // (for testing purposes, you might want to pair with any available device)
            return pairedDevices.firstOrNull()
            
        } catch (e: SecurityException) {
            Log.e("BluetoothConnection", "Permission denied when accessing paired devices", e)
            return null
        }
    }
    
    private fun startReadThread() {
        readThread = Thread {
            val buffer = ByteArray(1024)
            var bytes: Int
            
            while (connected) {
                try {
                    bytes = inputStream!!.read(buffer)
                    val data = String(buffer, 0, bytes).trim()
                    
                    // Process received data
                    processReceivedData(data)
                    
                    listener.onDataReceived(data)
                    
                } catch (e: IOException) {
                    Log.e("BluetoothConnection", "Read failed", e)
                    if (connected) {
                        listener.onError("Connection lost")
                        disconnect()
                    }
                    break
                }
            }
        }
        readThread!!.start()
    }
    
    private fun processReceivedData(data: String) {
        try {
            // Expected format from ESP32: "POT:512" or just "512"
            val potValue = if (data.startsWith("POT:")) {
                data.substring(4).toFloatOrNull()
            } else {
                data.toFloatOrNull()
            }
            
            potValue?.let { value ->
                // Convert potentiometer value (0-1023) to normalized value (0-1023)
                val normalizedValue = value.coerceIn(0f, 1023f)
                steeringListener?.invoke(normalizedValue)
            }
            
        } catch (e: Exception) {
            Log.e("BluetoothConnection", "Error processing data: $data", e)
        }
    }
    
    fun sendData(data: String) {
        if (!connected || outputStream == null) {
            listener.onError("Not connected")
            return
        }
        
        Thread {
            try {
                outputStream!!.write(data.toByteArray())
                outputStream!!.flush()
            } catch (e: IOException) {
                Log.e("BluetoothConnection", "Send failed", e)
                listener.onError("Send failed: ${e.message}")
            }
        }.start()
    }
    
    fun disconnect() {
        connected = false
        
        try {
            readThread?.interrupt()
            inputStream?.close()
            outputStream?.close()
            bluetoothSocket?.close()
        } catch (e: IOException) {
            Log.e("BluetoothConnection", "Error closing connection", e)
        }
        
        inputStream = null
        outputStream = null
        bluetoothSocket = null
        readThread = null
        
        listener.onConnectionStateChanged(false)
    }
    
    fun isConnected(): Boolean = connected
}