package com.rohit.pocketbase_server_flutter

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import pocketbaseMobile.PocketbaseMobile

class PocketbaseService : Service() {
    private lateinit var dataPath: String
    private var serviceWakeLock = "PocketbaseServiceWakelock"
    private var hostname = Utils.defaultHostName
    private var port = Utils.defaultPort
    private var enablePocketbaseApiLogs = false
    private val uiScope = CoroutineScope(Dispatchers.Main + Job())
    private var wakeLock: PowerManager.WakeLock? = null

    companion object {
        const val stopServiceAction = "StopService"
        var isRunning = false
    }

    override fun onCreate() {
        super.onCreate()
        dataPath = Utils.getStoragePath(this)
        startForeground()
        startWakelock()
        setPocketbaseCallbackListener()
        isRunning = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == stopServiceAction) {
            stopSelf()
        } else {
            intent?.extras?.getString("dataPath")?.let { dataPath = it }
            intent?.extras?.getString("hostName")?.let { hostname = it }
            intent?.extras?.getString("port")?.let { port = it }
            enablePocketbaseApiLogs = intent?.extras?.getBoolean("enablePocketbaseApiLogs") ?: false
            startPocketbase(dataPath, hostname, port)
        }
        return super.onStartCommand(intent, flags, startId)
    }

    private fun startForeground() {
        val channelId = createNotificationChannel()
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
        // Close button Intent
        val pendingIntentFlag =
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val stopNotificationIntent = Intent(this, PocketbaseService::class.java)
        stopNotificationIntent.action = stopServiceAction
        val stopNotificationPendingIntent: PendingIntent = PendingIntent.getService(
            this, 0,
            stopNotificationIntent, pendingIntentFlag,
        )
        val notification = notificationBuilder
            .setOngoing(true)
            .setContentTitle("Pocketbase")
            .setContentText("Pocketbase running in background")
            .setSmallIcon(R.drawable.notification_icon)
            .setCategory(Notification.CATEGORY_SERVICE)
            .addAction(
                R.drawable.icon_close,
                "Stop",
                stopNotificationPendingIntent
            )
        startForeground(124412, notification.build())
    }

    private fun startPocketbase(dataPath: String, hostname: String, port: String) {
        uiScope.launch {
            withContext(Dispatchers.IO) {
                PocketbaseMobile.startPocketbase(dataPath, hostname, port, enablePocketbaseApiLogs)
            }
        }
    }

    private fun stopPocketbase() {
        uiScope.launch {
            withContext(Dispatchers.IO) {
                PocketbaseMobile.stopPocketbase()
            }
        }
    }

    private fun setPocketbaseCallbackListener() {
        PocketbaseMobile.registerNativeBridgeCallback { command, data ->
            sendBroadcastEvent(command, data)
            // return response back to pocketbase
            "response from native"
        }
    }

    private fun sendBroadcastEvent(type: String, event: String) {
        val intent = Intent(Utils.broadcastEventAction)
        intent.putExtra(Utils.broadcastEventType, type)
        intent.putExtra(Utils.broadcastEventData, event)
        sendBroadcast(intent)
    }

    @SuppressLint("WakelockTimeout")
    private fun startWakelock() {
        val powerManager = applicationContext.getSystemService(POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, serviceWakeLock)
        wakeLock?.acquire()
    }

    private fun stopWakelock() {
        wakeLock?.release()
    }

    private fun createNotificationChannel(): String {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return ""
        val chan = NotificationChannel(
            "pocketbase_service",
            "Pocketbase Background Service",
            NotificationManager.IMPORTANCE_LOW
        )
        chan.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        val service = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        service.createNotificationChannel(chan)
        return "pocketbase_service"
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        stopPocketbase()
        stopWakelock()
        isRunning = false
        super.onDestroy()
    }
}