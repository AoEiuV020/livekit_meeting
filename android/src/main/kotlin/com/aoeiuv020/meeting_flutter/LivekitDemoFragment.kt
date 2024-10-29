package com.aoeiuv020.meeting_flutter

import android.util.Base64
import androidx.annotation.UiThread
import com.aoeiuv020.meeting_flutter.util.JsonUtil
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import io.flutter.plugin.common.MethodChannel

@Suppress("MemberVisibilityCanBePrivate")
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
    var eventListener: EventListener? = null

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
            try {
                var ret = eventListener?.onEvent(call.method, call.arguments)
                if (ret is Unit) {
                    ret = null
                }
                result.success(ret)
            } catch (e: NoSuchMethodException) {
                result.notImplemented()
            } catch (e: MeetingRpcException) {
                result.error(e.errorCode, e.message, e.errorDetails)
            } catch (e: Exception) {
                result.error("-1", e.message, null)
            }
        }
        invokeMethod("setInterceptHangupEnabled", mapOf("enabled" to true), null)
    }

    @UiThread
    fun invokeMethod(method: String, arguments: Any?, callback: MethodChannel.Result?) {
        channel.invokeMethod(method, arguments, callback)
    }

    fun hangup() {
        invokeMethod("hangup", null, null)
    }

    fun setAudioMute(muted: Boolean) {
        invokeMethod("setAudioMute", mapOf("muted" to muted), null)
    }

    fun setVideoMute(muted: Boolean) {
        invokeMethod("setVideoMute", mapOf("muted" to muted), null)
    }

    fun toggleCamera() {
        invokeMethod("toggleCamera", null, null)
    }

    @Suppress("UNCHECKED_CAST")
    abstract class EventListener {
        private fun obj(arguments: Any?): Map<String, Any> = (arguments as Map<String, Any>)
        open fun onEvent(method: String, arguments: Any?): Any? = when (method) {
            "interceptHangup" -> interceptHangup()
            "onHangup" -> onHangup()
            "onAudioMuteChanged" -> onAudioMuteChanged(obj(arguments)["muted"] as Boolean)
            "onVideoMuteChanged" -> onVideoMuteChanged(obj(arguments)["muted"] as Boolean)
            else -> throw NoSuchMethodException()
        }

        open fun interceptHangup(): Boolean {
            return false
        }

        open fun onVideoMuteChanged(muted: Boolean) {

        }

        open fun onAudioMuteChanged(muted: Boolean) {

        }

        open fun onHangup() {
        }
    }

}