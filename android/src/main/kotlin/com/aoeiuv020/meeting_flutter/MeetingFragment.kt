package com.aoeiuv020.meeting_flutter

import io.flutter.embedding.android.FlutterFragment

class MeetingFragment : FlutterFragment() {
    companion object {
        @JvmStatic
        fun create(options: MeetingOptions): MeetingFragment =
            NewEngineFragmentBuilder(MeetingFragment::class.java)
                .dartEntrypointArgs(
                    listOf(
                        "--serverUrl", options.serverUrl,
                        "--room", options.room,
                        "--name", options.name
                    )
                ).build()
    }
}