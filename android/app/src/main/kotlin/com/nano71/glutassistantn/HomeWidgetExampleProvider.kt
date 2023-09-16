package com.nano71.glutassistantn

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider


class HomeWidgetExampleProvider : HomeWidgetProvider() {

    private fun manuallyUpdateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {

    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                //Open App on Widget Click
                setOnClickPendingIntent(
                    R.id.widget_title,
                    PendingIntent.getActivity(context, 0, Intent(context, MainActivity::class.java), 0)
                )
                setTextViewText(
                    R.id.widget_title, widgetData.getString("title", null)
                        ?: "No Title Set"
                )
                setTextViewText(
                    R.id.widget_message, widgetData.getString("message", null)
                        ?: "No Message Set"
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

