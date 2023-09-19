package com.nano71.glutassistantn

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.util.Log
import android.util.SizeF
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.text.DateFormat
import java.text.DateFormat.getDateInstance
import java.text.SimpleDateFormat
import java.time.Instant
import java.util.Date

@Serializable
data class CustomData(val value: List<List<String>>)

private const val TAG = "appwidget"

class HomeWidgetExampleProvider : HomeWidgetProvider() {

    @RequiresApi(Build.VERSION_CODES.S)
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        Log.d(TAG, "HomeWidgetExampleProvider.onUpdate")
        appWidgetIds.forEach { widgetId ->
            fun updateContent(remoteViews: RemoteViews) {
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                remoteViews.setOnClickPendingIntent(
                    R.id.widget_container, pendingIntent
                )

                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("homeWidgetExample://refresh")
                )

                remoteViews.setOnClickPendingIntent(R.id.widget_title, backgroundIntent)

                val originalTodaySchedule: String? = widgetData.getString("todaySchedule", null)
                if (originalTodaySchedule != null) {
                    val todaySchedule: List<List<String>> = Json.decodeFromString<CustomData>(originalTodaySchedule).value
                    Log.d(TAG, "updateContent: todaySchedule:")

                }

                val originalTomorrowSchedule: String? = widgetData.getString("tomorrowSchedule", null)
                if (originalTomorrowSchedule != null) {
                    val tomorrowSchedule: List<List<String>> = Json.decodeFromString<CustomData>(originalTomorrowSchedule).value
                    Log.d(TAG, "updateContent: tomorrowSchedule")
                }

                remoteViews.setTextViewText(R.id.widget_title, widgetData.getString("title", null))
                val timeDate: Long = Instant.now().epochSecond
                Log.d(TAG, "updateContent: $timeDate")
                remoteViews.setTextViewText(
                    R.id.widget_message,
                    "$timeDate"
                )
            }


            val smallViews = RemoteViews(context.packageName, R.layout.widget_small).apply {
                updateContent(this)
            }
            val mediumViews = RemoteViews(context.packageName, R.layout.widget_medium).apply {
                updateContent(this)
            }

            appWidgetManager.updateAppWidget(
                widgetId, RemoteViews(
                    mapOf(
                        SizeF(110.0f, 110.0f) to smallViews,
                        SizeF(170.0f, 110.0f) to mediumViews
                    )
                )
            )
        }
    }
}

