package com.nano71.glutassistantn

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import android.content.BroadcastReceiver
import es.antonborri.home_widget.HomeWidgetBackgroundWorker
import io.flutter.FlutterInjector

class HomeWidgetBackgroundReceiver : HomeWidgetBackgroundReceiver2() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("appwidget", "HomeWidgetBackgroundReceiver.onReceive")
        Log.d("appwidget", intent.action.toString())
        val widgetManager = AppWidgetManager.getInstance(context)
        val componentName = ComponentName(context, HomeWidgetProvider::class.java)
        val widgetIds = widgetManager.getAppWidgetIds(componentName)

        if (intent.action.toString() == "es.antonborri.home_widget.action.INTERACTIVITY" &&
            intent.data.toString() == "homeWidgetExample://refresh"
        ) {

            val remoteViews = RemoteViews(context.packageName, R.layout.widget_small)

            remoteViews.setTextViewText(R.id.loading_text, "组件更新中...")
            remoteViews.setViewVisibility(R.id.loading_text, View.VISIBLE)
            remoteViews.setViewVisibility(R.id.widget_container, View.GONE)
            remoteViews.setViewVisibility(R.id.refresh_icon, View.GONE)

            widgetIds.forEach { widgetId ->
                widgetManager.updateAppWidget(widgetId, remoteViews)

                Handler(Looper.getMainLooper()).postDelayed({
                    remoteViews.setViewVisibility(R.id.loading_text, View.GONE)
                    remoteViews.setViewVisibility(R.id.widget_container, View.VISIBLE)
                    remoteViews.setViewVisibility(R.id.refresh_icon, View.VISIBLE)
                    widgetManager.updateAppWidget(widgetId, remoteViews)
                }, 1000)
            }
        } else {
            Log.d("appwidget", "非目标 Intent，不做更新: ${intent.action}, ${intent.data}")
        }
        super.onReceive(context, intent)

    }
}

open class HomeWidgetBackgroundReceiver2 : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val flutterLoader = FlutterInjector.instance().flutterLoader()
        flutterLoader.startInitialization(context)
        flutterLoader.ensureInitializationComplete(context, null)
        HomeWidgetBackgroundWorker.enqueueWork(context, intent)
    }
}
