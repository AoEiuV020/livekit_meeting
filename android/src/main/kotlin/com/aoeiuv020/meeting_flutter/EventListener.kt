package com.aoeiuv020.meeting_flutter

interface EventListener {
    fun onEvent(method: String, arguments: Any?): Any?
}