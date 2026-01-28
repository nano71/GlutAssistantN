package com.nano71.glutassistantn
import android.annotation.SuppressLint
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val channel = "com.nano71.glutassistantn/widget_check"
    @SuppressLint("UseKtx")
    override fun onCreate(savedInstanceState: Bundle?) {
        // ⚠️ 一定要在 super.onCreate 之前
//        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
//        val color = prefs.getInt(
//            "flutter.splashColor",
//            0xFFFAFAFA.toInt() // 默认灰白色
//        )
//
//        window.setBackgroundDrawable(ColorDrawable(color))

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