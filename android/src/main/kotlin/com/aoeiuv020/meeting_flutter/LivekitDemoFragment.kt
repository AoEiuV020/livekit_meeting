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

    val channel get() = MeetingFlutterPlugin.channel
    var eventListener: EventListener?
        get() = MeetingFlutterPlugin.eventListener
        set(value) {
            MeetingFlutterPlugin.eventListener = value
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 必须加上这个才能使用flutter插件，
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine)
        initChannel()
    }

    private fun initChannel() {
        // 默认启用拦截挂断，
        invokeMethod("setInterceptHangupEnabled", mapOf("enabled" to true), null)
    }

    override fun onDetach() {
        super.onDetach()
        eventListener = null
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

}