package com.nano71.glutassistantn

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context


object AppWidgetUtils {

    fun isWidgetAdded(context: Context): Boolean {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val thisWidget = ComponentName(context, HomeWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
        return appWidgetIds.isNotEmpty()
    }
}