package com.aoeiuv020.meeting_flutter

@Suppress("UNCHECKED_CAST")
abstract class BaseEventListener : EventListener {
    private fun obj(arguments: Any?): Map<String, Any> = (arguments as Map<String, Any>)
    override fun onEvent(method: String, arguments: Any?): Any? = when (method) {
        "interceptHangUp" -> mapOf("hangUp" to interceptHangUp())
        "onDisconnected" -> onDisconnected()
        "onAudioMuteChanged" -> onAudioMuteChanged(obj(arguments)["muted"] as Boolean)
        "onVideoMuteChanged" -> onVideoMuteChanged(obj(arguments)["muted"] as Boolean)
        else -> throw NoSuchMethodException()
    }

    open fun interceptHangUp(): Boolean {
        return false
    }

    open fun onVideoMuteChanged(muted: Boolean) {

    }

    open fun onAudioMuteChanged(muted: Boolean) {

    }

    open fun onDisconnected() {
    }
}