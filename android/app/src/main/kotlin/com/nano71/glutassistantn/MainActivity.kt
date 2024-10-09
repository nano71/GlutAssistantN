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
//    @RequiresApi(Build.VERSION_CODES.S)
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
    // Hides the systems bar (status bar & navigation bar).
//        val windowInsetsController = ViewCompat.getWindowInsetsController(window.decorView) ?: return
//        windowInsetsController.hide(WindowInsetsCompat.Type.systemBars())
    // Get the top-right rounded corner from WindowInsets.
//        val view = window.decorView
//        val windowInsets = view.rootWindowInsets
//        val topRight = windowInsets?.getRoundedCorner(RoundedCorner.POSITION_TOP_RIGHT) ?: return
//        Log.d("TAG", "onCreate: ${topRight.radius}")
//        return
//    }
}
