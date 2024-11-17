package com.aoeiuv020.meeting_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** MeetingFlutterPlugin */
class MeetingFlutterPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  companion object {
    @JvmStatic
    lateinit var channel : MethodChannel
    var eventListener: EventListener? = null
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "meeting_flutter")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
      return
    }
    val eventListener = eventListener
    if (eventListener == null) {
      result.notImplemented()
      return
    }
    // 处理来自Flutter端的调用
    try {
      var ret = eventListener.onEvent(call.method, call.arguments)
      if (ret is Unit) {
        ret = null
      }
      result.success(ret)
      return
    } catch (e: NoSuchMethodException) {
      result.notImplemented()
      return
    } catch (e: MeetingRpcException) {
      result.error(e.errorCode, e.message, e.errorDetails)
      return
    } catch (e: Exception) {
      result.error("-1", e.message, null)
      return
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
