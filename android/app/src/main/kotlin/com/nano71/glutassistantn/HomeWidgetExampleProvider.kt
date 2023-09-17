package com.nano71.glutassistantn

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.SizeF
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import es.antonborri.home_widget.HomeWidgetProvider


class HomeWidgetExampleProvider : HomeWidgetProvider() {


    @RequiresApi(Build.VERSION_CODES.S)
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            fun updateContent(remoteViews: RemoteViews) {
                remoteViews.setOnClickPendingIntent(
                    R.id.widget_container, PendingIntent.getActivity(context, 0, Intent(context, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE)
                )
                remoteViews.setTextViewText(
                    R.id.widget_title, widgetData.getString("title", null)
                )
                remoteViews.setTextViewText(
                    R.id.widget_message, widgetData.getString("message", null)
                )
            }

            val smallViews = RemoteViews(context.packageName, R.layout.widget_small).apply {
                updateContent(this)
            }
            val mediumViews = RemoteViews(context.packageName, R.layout.widget_medium).apply {
                updateContent(this)
            }

            appWidgetManager.updateAppWidget(widgetId, RemoteViews(mapOf(
                SizeF(110.0f, 110.0f) to smallViews,
                SizeF(170.0f, 110.0f) to mediumViews
            )))
        }
    }
}

