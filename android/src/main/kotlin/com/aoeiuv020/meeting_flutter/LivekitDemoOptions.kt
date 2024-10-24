package com.aoeiuv020.meeting_flutter

import androidx.annotation.Keep
import java.io.Serializable

@Keep
class LivekitDemoOptions(
    val serverUrl: String,
    val room: String,
    val name: String,
    val autoConnect: Boolean = true,
) : Serializable
