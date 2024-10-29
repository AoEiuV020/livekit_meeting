package com.aoeiuv020.meeting_flutter

class MeetingRpcException(
    val errorCode: String,
    message: String,
    val errorDetails: Any?,
    cause: Throwable?
) : RuntimeException(message, cause)