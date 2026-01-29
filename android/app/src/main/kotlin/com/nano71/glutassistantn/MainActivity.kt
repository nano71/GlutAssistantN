package com.nano71.glutassistantn
import android.os.Build
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val channel = "com.nano71.glutassistantn/widget_check"

    override fun onCreate(savedInstanceState: Bundle?) {
        // 必须在 super.onCreate() 之前调用
        val splashScreen = installSplashScreen()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setKeepOnScreenCondition { false }
        }
        setTheme(R.style.AppTheme)

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