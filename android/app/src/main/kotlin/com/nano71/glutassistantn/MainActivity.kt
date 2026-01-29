package com.nano71.glutassistantn
import android.os.Bundle
import android.util.Log
import androidx.core.content.edit
import androidx.core.graphics.drawable.toDrawable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val channel = "com.nano71.glutassistantn/widget_check"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "app/theme"
        ).setMethodCallHandler { call, result ->
            if (call.method == "saveLaunchColor") {
                val color = (call.arguments as Number).toInt()
                getSharedPreferences("launch", MODE_PRIVATE)
                    .edit() {
                        putInt("bg_color", color)
                    }
                result.success(null)
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        val prefs = getSharedPreferences("launch", MODE_PRIVATE)
        val color = prefs.getInt("bg_color", 0xFFFAFAFA.toInt())
        Log.d("Launch", "color=${Integer.toHexString(color)}")

        window.setBackgroundDrawable(color.toDrawable())

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