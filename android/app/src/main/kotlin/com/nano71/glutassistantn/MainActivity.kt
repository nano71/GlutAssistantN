package com.nano71.glutassistantn

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val channel = "com.nano71.glutassistantn/widget_check"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, channel).setMethodCallHandler { call, result ->
                when (call.method) {
                    "isWidgetAdded" -> {
                        val isAdded = AppWidgetUtils.isWidgetAdded(this)
                        result.success(isAdded)
                    }

                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }
}