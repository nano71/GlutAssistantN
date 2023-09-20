package com.nano71.glutassistantn

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                if (call.method == "startMainApp") {
                    // 启动主程序
                    val intent = Intent(applicationContext, YourMainActivity::class.java)
                    startActivity(intent)
                }
            }
    }

    companion object {
        private const val CHANNEL_NAME = "your_channel_name"
    }
}