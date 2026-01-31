package com.nano71.glutassistantn

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.widget.RemoteViews


object AppWidgetUtils {

    fun isWidgetAdded(context: Context): Boolean {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val thisWidget = ComponentName(context, HomeWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
        return appWidgetIds.isNotEmpty()
    }

    private val frames = intArrayOf(
        R.drawable.refresh_line,
        R.drawable.refresh_line_90,
        R.drawable.refresh_line_180,
    )

    fun startRotate(
        context: Context,
        appWidgetId: Int,
        layoutId:Int
    ) {
        Thread {
            val appWidgetManager =  AppWidgetManager.getInstance(context)
            repeat(3) { i ->
                val rv = RemoteViews(context.packageName, layoutId)
                rv.setImageViewResource(R.id.refresh_icon, frames[i])

                appWidgetManager.updateAppWidget(appWidgetId, rv)
                Thread.sleep(60) // 控制转速
            }
        }.start()
    }
}

