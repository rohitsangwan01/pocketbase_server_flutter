package com.rohit.pocketbase_server_flutter

import android.content.Context

class Utils {
    companion object {
        const val defaultHostName = "127.0.0.1"
        const val defaultPort = "8090"
        const val broadcastEventAction = "pocketbase_broadcast_action"
        const val broadcastEventType = "pocketbase_broadcast_event_type"
        const val broadcastEventData = "pocketbase_broadcast_event_data"

        fun getStoragePath(context: Context): String {
            val directory = context.getExternalFilesDir(null) ?: context.filesDir
            return directory.absolutePath
        }
    }
}
