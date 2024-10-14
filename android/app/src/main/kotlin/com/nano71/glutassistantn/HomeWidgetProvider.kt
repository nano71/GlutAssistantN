package com.nano71.glutassistantn

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.res.Resources
import android.net.Uri
import android.os.Build
import android.util.DisplayMetrics
import android.util.Log
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.time.LocalDateTime
import kotlin.math.roundToInt

@Serializable
data class CustomData(val value: List<List<String>>)

private const val TAG = "appwidget"

class HomeWidgetProvider : HomeWidgetProvider() {
    private var toastCount: Int = 0
    private var isInitialized: Boolean = false
    private val rowList: List<Int> = listOf(
        R.id.row_1,
        R.id.row_2,
        R.id.row_3
    )
    private val labelIdList: List<Int> = listOf(
        R.id.label_1,
        R.id.label_2,
        R.id.label_3
    )
    private val courseNameList: List<Int> = listOf(
        R.id.course_name_1,
        R.id.course_name_2,
        R.id.course_name_3
    )
    private val addressList: List<Int> = listOf(
        R.id.address_1,
        R.id.address_2,
        R.id.address_3
    )

    private fun customParser(data: List<List<String>>): List<List<String>> {
        println("HomeWidgetExampleProvider.customParser")
        val mergedDataMap = mutableMapOf<Pair<String, String>, MutableList<String>>()
        for (item in data) {
            val key = Pair(item[0], item[1])
            if (!mergedDataMap.containsKey(key)) {
                mergedDataMap[key] = mutableListOf()
            }
            mergedDataMap[key]!!.add(item[2])
        }
        val mergedDataList = mutableListOf<List<String>>()
        for ((key, values) in mergedDataMap) {
            val startIndex = values.first()
            val endIndex = values.last()
            val mergedItem = mutableListOf(key.first, key.second, "$startIndex–$endIndex")
            mergedDataList.add(mergedItem)
        }
        return mergedDataList
    }

    private fun emoji(lessonCount: Int): String {
        return when (lessonCount) {
            0 -> "😋"
            1, 2 -> "🤪"
            3, 4 -> "🙄"
            5, 6 -> "😑"
            else -> "😑"
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun setData(remoteViews: RemoteViews, originalData: List<List<String>>, isSmall: Boolean, isToday: Boolean) {
        println("HomeWidgetExampleProvider.setData")
//        remoteViews.setViewVisibility(R.id.refresh_icon, View.VISIBLE)
        val data: List<List<String>> = customParser(originalData)
        val lessonCount: Int = data.size
        val todayText: String = if (isToday) "还" else ""

        if (isSmall) {
            remoteViews.setTextViewText(R.id.widget_message, todayText + "有${lessonCount}节~")
        } else {
            remoteViews.setTextViewText(R.id.widget_message, emoji(lessonCount) + todayText + "有${lessonCount}节课~")
        }

        if (lessonCount == 1 || lessonCount == 2) {
            val lastClass: String = data.last()[2]
            val currentDateTime = LocalDateTime.now()
            val currentHour: Int = currentDateTime.hour
            if (currentHour > 19 && (lastClass.contains("10") || lastClass.contains("11"))) {
                setRowData(remoteViews, lessonCount, "然后", "玩,然后早些休息~", "Dormitory")
            } else {
                setRowData(remoteViews, lessonCount, "然后", "玩~", "Anywhere")
            }
        }

        for ((index, strings) in data.withIndex()) {
            if (index > 2)
                break
            setRowData(remoteViews, index, strings[2] + "节", strings[0], strings[1])
        }
    }

    private fun hideElements(remoteViews: RemoteViews) {
        println("HomeWidgetExampleProvider.hideElements")
        for (row in rowList) {
            remoteViews.setViewVisibility(row, View.GONE)
        }
    }

    private fun setRowData(remoteViews: RemoteViews, index: Int, label: String, courseName: String, address: String) {
        println("HomeWidgetExampleProvider.setRowData")
        remoteViews.setTextViewText(
            labelIdList[index],
            label
        )
        remoteViews.setTextViewText(
            courseNameList[index],
            courseName
        )
        remoteViews.setTextViewText(
            addressList[index],
            address
        )
        remoteViews.setViewVisibility(rowList[index], View.VISIBLE)
    }

    private fun nullValueTemplate(remoteViews: RemoteViews) {
//        remoteViews.setViewVisibility(R.id.refresh_icon, View.VISIBLE)
        setRowData(remoteViews, 0, "首先", "写作业", "Library")
        setRowData(remoteViews, 1, "然后", "开心的玩", "Anywhere")
        setRowData(remoteViews, 2, "最后", "回宿舍睡大觉", "Dormitory")
    }

    private fun bindOnClickEvent(context: Context, remoteViews: RemoteViews) {
        println("HomeWidgetExampleProvider.bindOnClickEvent")
        val pendingIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("homeWidgetExample://open")
        )

        val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("homeWidgetExample://refresh")
        )

        remoteViews.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
        remoteViews.setOnClickPendingIntent(R.id.refresh_icon, pendingIntentWithData)
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun updateContent(context: Context, widgetData: SharedPreferences, remoteViews: RemoteViews, isSmall: Boolean) {
        hideElements(remoteViews)
        if (!isInitialized)
            bindOnClickEvent(context, remoteViews)

        val originalTodaySchedule: String = widgetData.getString("todaySchedule", null) ?: "{'value':[]}"
        val todaySchedule: List<List<String>> = Json.decodeFromString<CustomData>(originalTodaySchedule).value
        if (todaySchedule.isNotEmpty()) {
            Log.d(TAG, "updateContent: todaySchedule:")
            setData(remoteViews, todaySchedule, isSmall, true)
        } else {
            val originalTomorrowSchedule: String = widgetData.getString("tomorrowSchedule", null) ?: "{'value':[]}"
            val tomorrowSchedule: List<List<String>> = Json.decodeFromString<CustomData>(originalTomorrowSchedule).value
            if (tomorrowSchedule.isNotEmpty()) {
                Log.d(TAG, "updateContent: tomorrowSchedule")
                setData(remoteViews, tomorrowSchedule, isSmall, false)
            } else {
                nullValueTemplate(remoteViews)
            }
        }

        val message: String? = widgetData.getString("message", "")

        if (!message.isNullOrEmpty()) {
            remoteViews.setTextViewText(R.id.widget_message, message)
        }

        remoteViews.setTextViewText(R.id.widget_title, widgetData.getString("title", null))
        remoteViews.setViewVisibility(R.id.loading_text, View.GONE)
        remoteViews.setViewVisibility(R.id.widget_container, View.VISIBLE)
        remoteViews.setViewVisibility(R.id.refresh_icon, View.VISIBLE)
    }


    @RequiresApi(Build.VERSION_CODES.S)
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        Log.d(TAG, "HomeWidgetExampleProvider.onUpdate")
        appWidgetIds.forEach { widgetId ->
            print("widgetId:")
            println(widgetId)
            val smallViews = RemoteViews(context.packageName, R.layout.widget_small).apply {
                updateContent(context, widgetData, this, true)
            }
            val mediumViews = RemoteViews(context.packageName, R.layout.widget_medium).apply {
                updateContent(context, widgetData, this, false)
            }
            appWidgetManager.updateAppWidget(
                widgetId, RemoteViews(
                    mapOf(
                        SizeF(180.0f, 110.0f) to smallViews,
                        SizeF(270.0f, 110.0f) to mediumViews
                    )
                )
            )
            toastCount = 0
            isInitialized = true
        }
        val screenInfo = ScreenInfo()
        screenInfo.getScreenInfo(context)
    }
}

class ScreenInfo {
    private lateinit var context: Context
    private lateinit var resources: Resources
    private var displayMetrics: DisplayMetrics = Resources.getSystem().displayMetrics
    fun getScreenInfo(context: Context) {
        this.context = context
        resources = context.resources
        Log.d(TAG, "getScreenInfo.getStatusBarHeightInDp: ${getStatusBarHeightInDp()}")
        Log.d(TAG, "getScreenInfo.getScreenWidthInDp: ${getScreenWidthInDp()}")
        Log.d(TAG, "getScreenInfo.getScreenHeightInDp: ${getScreenHeightInDp()}")
        Log.d(TAG, "getScreenInfo.getNavigationBarHeightInDp: ${getNavigationBarHeightInDp()}")
    }

    private fun getStatusBarHeightInDp(): Int {
        val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
        val statusBarHeightPx = resources.getDimensionPixelSize(resourceId)
        return pxToDp(statusBarHeightPx.toFloat())
    }

    private fun getScreenWidthInDp(): Int {
        return pxToDp(displayMetrics.widthPixels.toFloat())
    }

    private fun getScreenHeightInDp(): Int {
        return pxToDp(displayMetrics.heightPixels.toFloat())
    }

    private fun getNavigationBarHeightInDp(): Int {
        val resourceId = resources.getIdentifier("navigation_bar_height", "dimen", "android")
        val navigationBarHeightPx = resources.getDimensionPixelSize(resourceId)
        return pxToDp(navigationBarHeightPx.toFloat())
    }

    private fun pxToDp(px: Float): Int {
        return (px / (displayMetrics.densityDpi.toFloat() / DisplayMetrics.DENSITY_DEFAULT)).roundToInt()
    }


}

