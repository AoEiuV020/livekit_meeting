package com.aoeiuv020.meeting_flutter

import android.util.Base64
import androidx.annotation.UiThread
import com.aoeiuv020.meeting_flutter.util.JsonUtil
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class LivekitDemoFragment : FlutterFragment() {
    companion object {
        @JvmStatic
        fun create(options: LivekitDemoOptions): LivekitDemoFragment =
            NewEngineFragmentBuilder(LivekitDemoFragment::class.java)
                .dartEntrypointArgs(
                    listOf(
                        "--livekitDemoOptions",
                        Base64.encodeToString(
                            JsonUtil.toJson(options).toByteArray(),
                            Base64.NO_WRAP
                        )
                    )
                ).build()
    }

    private var _channel: MethodChannel? = null
    val channel get() = _channel!!
    private var onReady: Runnable? = null
    private val handlers = mutableMapOf<String, MethodChannel.MethodCallHandler>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 必须加上这个才能使用flutter插件，
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine)
        initChannel(flutterEngine)
    }

    private fun initChannel(flutterEngine: FlutterEngine) {
        // 创建MethodChannel
        _channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "meeting_rpc")
        channel.setMethodCallHandler { call, result ->
            // 处理来自Flutter端的调用
            val handler = handlers[call.method]
            handler?.onMethodCall(call, result)
                ?: result.notImplemented()
        }
        if (onReady != null) {
            onReady?.run()
            onReady = null
        }
    }

    fun postOnChannelReady(onReady: Runnable) {
        if (_channel != null) {
            onReady.run()
        } else {
            this.onReady = onReady
        }
    }

    fun registerMethod(method: String, callback: MethodChannel.MethodCallHandler) {
        handlers[method] = callback
    }

    @UiThread
    fun invokeMethod(method: String, arguments: Any?, callback: MethodChannel.Result?) {
        channel.invokeMethod(method, arguments, callback)
    }

    fun hangup() {
        invokeMethod("hangup", null, null)
    }

    fun interceptHangup(function: () -> Boolean) {
        registerMethod("interceptHangup", object : MethodChannel.MethodCallHandler {
            override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
                if (function.invoke()) {
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
        })
        invokeMethod("setInterceptHangupEnabled", mapOf("enabled" to true), null)
    }

}