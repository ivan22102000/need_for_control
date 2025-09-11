package com.needforcontrol.racing

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity(), BluetoothConnection.BluetoothConnectionListener {
    private lateinit var gameView: GameView
    private lateinit var btnConnect: Button
    private lateinit var tvConnectionStatus: TextView
    private lateinit var tvScore: TextView
    private lateinit var bluetoothConnection: BluetoothConnection
    
    private val REQUEST_ENABLE_BT = 1
    private val REQUEST_PERMISSIONS = 2

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        initViews()
        initBluetooth()
        checkPermissions()
    }
    
    private fun initViews() {
        gameView = findViewById(R.id.gameView)
        btnConnect = findViewById(R.id.btnConnect)
        tvConnectionStatus = findViewById(R.id.tvConnectionStatus)
        tvScore = findViewById(R.id.tvScore)
        
        btnConnect.setOnClickListener {
            if (bluetoothConnection.isConnected()) {
                bluetoothConnection.disconnect()
            } else {
                bluetoothConnection.connect()
            }
        }
        
        // Update score display
        gameView.setScoreListener { score ->
            runOnUiThread {
                tvScore.text = "Score: $score"
            }
        }
    }
    
    private fun initBluetooth() {
        bluetoothConnection = BluetoothConnection(this, this)
        
        // Set steering listener for game
        bluetoothConnection.setSteeringListener { steeringValue ->
            gameView.setSteering(steeringValue)
        }
    }
    
    private fun checkPermissions() {
        val permissions = arrayOf(
            Manifest.permission.BLUETOOTH,
            Manifest.permission.BLUETOOTH_ADMIN,
            Manifest.permission.BLUETOOTH_CONNECT,
            Manifest.permission.ACCESS_COARSE_LOCATION,
            Manifest.permission.ACCESS_FINE_LOCATION
        )
        
        val permissionsToRequest = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsToRequest.toTypedArray(), REQUEST_PERMISSIONS)
        }
    }
    
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == REQUEST_PERMISSIONS) {
            val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            if (!allGranted) {
                Toast.makeText(this, "Bluetooth permissions are required", Toast.LENGTH_LONG).show()
            }
        }
    }
    
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == REQUEST_ENABLE_BT) {
            if (resultCode != RESULT_OK) {
                Toast.makeText(this, "Bluetooth is required for this app", Toast.LENGTH_LONG).show()
            }
        }
    }
    
    // BluetoothConnectionListener implementation
    override fun onConnectionStateChanged(connected: Boolean) {
        runOnUiThread {
            tvConnectionStatus.text = if (connected) "Connected" else "Disconnected"
            btnConnect.text = if (connected) "Disconnect" else "Connect ESP32"
        }
    }
    
    override fun onDataReceived(data: String) {
        // Data processing is handled in BluetoothConnection
    }
    
    override fun onError(message: String) {
        runOnUiThread {
            Toast.makeText(this, "Error: $message", Toast.LENGTH_SHORT).show()
        }
    }
    
    override fun onResume() {
        super.onResume()
        gameView.resume()
    }
    
    override fun onPause() {
        super.onPause()
        gameView.pause()
    }
    
    override fun onDestroy() {
        super.onDestroy()
        bluetoothConnection.disconnect()
    }
}