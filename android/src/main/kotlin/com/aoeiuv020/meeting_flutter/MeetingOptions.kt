package com.aoeiuv020.meeting_flutter

import androidx.annotation.Keep
import java.io.Serializable

@Keep
class MeetingOptions(
    val serverUrl: String,
    val room: String,
    val name: String,
) : Serializable
