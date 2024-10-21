package com.aoeiuv020.meeting_flutter_example

import android.app.AlertDialog
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    lateinit var channel: MethodChannel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 创建MethodChannel
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "meeting_rpc")
        channel.setMethodCallHandler { call, result ->
            // 处理来自Flutter端的调用
            when (call.method) {
                "interceptHangup" -> {
                    result.success(interceptHangup())
                }
                else -> result.notImplemented()
            }
        }

        // 调用Android方法
        channel.invokeMethod("setInterceptHangupEnabled", mapOf("enabled" to true))

    }
    private fun interceptHangup(): Boolean {
        AlertDialog.Builder(this)
            .setTitle("确认挂断")
            .setMessage("确定离开当前会议吗？")
            .setPositiveButton("是") { dialog, _ ->
                channel.invokeMethod("hangup", null)
                dialog.dismiss()
            }
            .setNegativeButton("否") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
        return true

    }
}
