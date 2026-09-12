package com.mlabs.borlawms

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)
            val channelIds = listOf(
                "ride_requests" to "Ride Requests",
                "scheduled_rides" to "Scheduled Rides",
                "client_updates" to "Client Updates",
                "scheduled_accepted" to "Scheduled Accepted",
                "recycling_requests" to "Recycling Requests",
                "recycling_status" to "Recycling Status",
                "test_notifications" to "Test Notifications",
                "high_importance_channel" to "High Importance Notifications"
            )
            channelIds.forEach { (id, name) ->
                manager.createNotificationChannel(
                    NotificationChannel(id, name, NotificationManager.IMPORTANCE_HIGH)
                )
            }
        }
    }
}