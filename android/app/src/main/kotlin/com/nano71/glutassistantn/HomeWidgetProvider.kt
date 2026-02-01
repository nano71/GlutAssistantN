package com.nano71.glutassistantn

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import androidx.core.net.toUri
import es.antonborri.home_widget.HomeWidgetProvider
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.time.LocalDateTime

@Serializable
data class CustomData(val value: List<List<String>>)

private const val TAG = "appwidget"

class HomeWidgetProvider : HomeWidgetProvider() {
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
            mergedDataMap.getOrPut(key) { mutableListOf() }.add(item[2])
        }

        val mergedDataList = mutableListOf<List<String>>()
        for ((key, values) in mergedDataMap) {
            val sortedValues = values.mapNotNull { it.toIntOrNull() }.sorted()
            val used = BooleanArray(sortedValues.size) { false }

            var i = 0
            while (i < sortedValues.size) {
                if (used[i]) {
                    i++
                    continue
                }

                val current = sortedValues[i]

                // Try 3-segment merge for >= 9
                if (i + 2 < sortedValues.size &&
                    sortedValues[i + 1] == current + 1 &&
                    sortedValues[i + 2] == current + 2 &&
                    current >= 9
                ) {
                    mergedDataList.add(listOf(key.first, key.second, "$current–${current + 2}"))
                    used[i] = true
                    used[i + 1] = true
                    used[i + 2] = true
                    i += 3
                    continue
                }

                // Try 2-segment merge
                if (i + 1 < sortedValues.size &&
                    sortedValues[i + 1] == current + 1 &&
                    !used[i + 1]
                ) {
                    mergedDataList.add(listOf(key.first, key.second, "$current–${current + 1}"))
                    used[i] = true
                    used[i + 1] = true
                    i += 2
                    continue
                }

                // Single value
                mergedDataList.add(listOf(key.first, key.second, "$current"))
                used[i] = true
                i++
            }
        }

        println("mergedDataList:")
        println(mergedDataList)
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

    private fun bindOnClickEvent(context: Context, remoteViews: RemoteViews, isSmall: Boolean, widgetId: Int) {
        println("HomeWidgetExampleProvider.bindOnClickEvent")
        var flags = PendingIntent.FLAG_UPDATE_CURRENT

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = PendingIntent.FLAG_IMMUTABLE
        }

        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = "homeWidgetExample://open".toUri()
        }

        val pendingIntent = PendingIntent.getActivity(context, widgetId, intent, flags)

        val refreshIntent = Intent(context, com.nano71.glutassistantn.HomeWidgetBackgroundReceiver::class.java).apply {
            action = "es.antonborri.home_widget.action.INTERACTIVITY"
            data = "homeWidgetExample://refresh".toUri()
        }

        val refreshPendingIntent = PendingIntent.getBroadcast(context, 1742968988, refreshIntent, flags)

        remoteViews.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
        remoteViews.setOnClickPendingIntent(R.id.refresh_icon, refreshPendingIntent)


    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        Log.d(TAG, "HomeWidgetExampleProvider.onReceive")

        Log.d(TAG, intent?.action.toString())

    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun updateContent(widgetData: SharedPreferences, remoteViews: RemoteViews, isSmall: Boolean) {
        hideElements(remoteViews)

        val originalTodaySchedule: String = widgetData.getString("todaySchedule", null) ?: """{"value":[]}"""

        val todaySchedule: List<List<String>> = Json.decodeFromString<CustomData>(originalTodaySchedule).value
        if (todaySchedule.isNotEmpty()) {
            Log.d(TAG, "updateContent: todaySchedule:")
            setData(remoteViews, todaySchedule, isSmall, true)
        } else {
            val originalTomorrowSchedule: String = widgetData.getString("tomorrowSchedule", null) ?: """{"value":[]}"""
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
                updateContent(widgetData, this, true)
                bindOnClickEvent(context, this, true, widgetId)

            }
            val mediumViews = RemoteViews(context.packageName, R.layout.widget_medium).apply {
                updateContent(widgetData, this, false)
                bindOnClickEvent(context, this, false, widgetId)

            }

            appWidgetManager.updateAppWidget(
                widgetId, RemoteViews(
                    mapOf(
                        SizeF(180.0f, 110.0f) to smallViews,
                        SizeF(270.0f, 110.0f) to mediumViews
                    )
                )
            )
        }
    }
}
