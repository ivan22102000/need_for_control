package com.needforcontrol.racing

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.view.SurfaceHolder
import android.view.SurfaceView
import kotlin.math.abs
import kotlin.random.Random

class GameView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : SurfaceView(context, attrs, defStyleAttr), SurfaceHolder.Callback {

    private var gameThread: GameThread? = null
    private var paint = Paint()
    
    // Game state
    private var screenWidth = 0
    private var screenHeight = 0
    private var roadWidth = 0
    private var laneCount = 3
    private var laneWidth = 0
    
    // Player car
    private var playerCar = Car(0f, 0f, 80f, 160f)
    private var steering = 0f // -1 to 1, controlled by ESP32 potentiometer
    
    // Obstacles
    private val obstacles = mutableListOf<Car>()
    private var obstacleSpawnTimer = 0L
    private val obstacleSpawnInterval = 2000L // 2 seconds
    
    // Road animation
    private var roadOffset = 0f
    private val roadSpeed = 5f
    
    // Game state
    private var score = 0
    private var gameRunning = true
    private var scoreListener: ((Int) -> Unit)? = null
    
    init {
        holder.addCallback(this)
        paint.isAntiAlias = true
    }
    
    fun setScoreListener(listener: (Int) -> Unit) {
        scoreListener = listener
    }
    
    fun setSteering(value: Float) {
        // Convert ESP32 potentiometer value (0-1023) to steering (-1 to 1)
        steering = (value / 512f) - 1f
        steering = steering.coerceIn(-1f, 1f)
    }
    
    override fun surfaceCreated(holder: SurfaceHolder) {
        // Surface created
    }
    
    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        screenWidth = width
        screenHeight = height
        roadWidth = (width * 0.8f).toInt()
        laneWidth = roadWidth / laneCount
        
        // Position player car
        playerCar.x = screenWidth / 2f - playerCar.width / 2f
        playerCar.y = screenHeight - 200f
        
        startGame()
    }
    
    override fun surfaceDestroyed(holder: SurfaceHolder) {
        stopGame()
    }
    
    private fun startGame() {
        gameThread = GameThread()
        gameThread?.start()
    }
    
    private fun stopGame() {
        gameThread?.running = false
        gameThread?.join()
    }
    
    fun resume() {
        if (gameThread?.running != true) {
            startGame()
        }
    }
    
    fun pause() {
        stopGame()
    }
    
    private inner class GameThread : Thread() {
        var running = false
        
        override fun run() {
            running = true
            var lastTime = System.currentTimeMillis()
            
            while (running) {
                val currentTime = System.currentTimeMillis()
                val deltaTime = currentTime - lastTime
                lastTime = currentTime
                
                if (gameRunning) {
                    update(deltaTime)
                }
                draw()
                
                try {
                    sleep(16) // ~60 FPS
                } catch (e: InterruptedException) {
                    break
                }
            }
        }
    }
    
    private fun update(deltaTime: Long) {
        // Update road animation
        roadOffset += roadSpeed
        if (roadOffset >= 100f) {
            roadOffset = 0f
        }
        
        // Update player car position based on steering
        val carSpeed = 8f
        playerCar.x += steering * carSpeed
        
        // Keep player car within road bounds
        val roadLeft = (screenWidth - roadWidth) / 2f
        val roadRight = roadLeft + roadWidth
        playerCar.x = playerCar.x.coerceIn(roadLeft, roadRight - playerCar.width)
        
        // Spawn obstacles
        if (System.currentTimeMillis() - obstacleSpawnTimer > obstacleSpawnInterval) {
            spawnObstacle()
            obstacleSpawnTimer = System.currentTimeMillis()
        }
        
        // Update obstacles
        obstacles.removeAll { obstacle ->
            obstacle.y += roadSpeed * 2
            obstacle.y > screenHeight
        }
        
        // Check collisions
        checkCollisions()
        
        // Update score
        score += 1
        scoreListener?.invoke(score)
    }
    
    private fun spawnObstacle() {
        val roadLeft = (screenWidth - roadWidth) / 2f
        val lane = Random.nextInt(laneCount)
        val x = roadLeft + lane * laneWidth + (laneWidth - 60f) / 2f
        
        val obstacle = Car(x, -160f, 60f, 120f)
        obstacles.add(obstacle)
    }
    
    private fun checkCollisions() {
        obstacles.forEach { obstacle ->
            if (playerCar.collidesWith(obstacle)) {
                gameRunning = false
                // Game over logic could be added here
            }
        }
    }
    
    private fun draw() {
        val canvas = holder.lockCanvas() ?: return
        
        try {
            // Clear screen
            canvas.drawColor(Color.parseColor("#1E1E1E"))
            
            // Draw road
            drawRoad(canvas)
            
            // Draw player car
            drawCar(canvas, playerCar, Color.parseColor("#0088FF"))
            
            // Draw obstacles
            obstacles.forEach { obstacle ->
                drawCar(canvas, obstacle, Color.parseColor("#FF4444"))
            }
            
            // Draw UI
            if (!gameRunning) {
                drawGameOver(canvas)
            }
            
        } finally {
            holder.unlockCanvasAndPost(canvas)
        }
    }
    
    private fun drawRoad(canvas: Canvas) {
        val roadLeft = (screenWidth - roadWidth) / 2f
        val roadRight = roadLeft + roadWidth
        
        // Draw road background
        paint.color = Color.parseColor("#404040")
        canvas.drawRect(roadLeft, 0f, roadRight, screenHeight.toFloat(), paint)
        
        // Draw lane markers
        paint.color = Color.WHITE
        paint.strokeWidth = 4f
        
        for (i in 1 until laneCount) {
            val x = roadLeft + i * laneWidth
            var y = -roadOffset
            
            while (y < screenHeight) {
                canvas.drawLine(x, y, x, y + 50f, paint)
                y += 100f
            }
        }
        
        // Draw road borders
        paint.strokeWidth = 8f
        canvas.drawLine(roadLeft, 0f, roadLeft, screenHeight.toFloat(), paint)
        canvas.drawLine(roadRight, 0f, roadRight, screenHeight.toFloat(), paint)
    }
    
    private fun drawCar(canvas: Canvas, car: Car, color: Int) {
        paint.color = color
        canvas.drawRect(car.x, car.y, car.x + car.width, car.y + car.height, paint)
        
        // Draw car details
        paint.color = Color.BLACK
        paint.strokeWidth = 2f
        canvas.drawRect(car.x + 10, car.y + 20, car.x + car.width - 10, car.y + car.height - 20, paint)
    }
    
    private fun drawGameOver(canvas: Canvas) {
        paint.color = Color.parseColor("#AA000000")
        canvas.drawRect(0f, 0f, screenWidth.toFloat(), screenHeight.toFloat(), paint)
        
        paint.color = Color.WHITE
        paint.textSize = 64f
        paint.textAlign = Paint.Align.CENTER
        canvas.drawText("GAME OVER", screenWidth / 2f, screenHeight / 2f, paint)
        
        paint.textSize = 32f
        canvas.drawText("Final Score: $score", screenWidth / 2f, screenHeight / 2f + 80f, paint)
    }
}

data class Car(
    var x: Float,
    var y: Float,
    val width: Float,
    val height: Float
) {
    fun collidesWith(other: Car): Boolean {
        return x < other.x + other.width &&
                x + width > other.x &&
                y < other.y + other.height &&
                y + height > other.y
    }
}