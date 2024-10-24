package com.aoeiuv020.meeting_flutter

import io.flutter.embedding.android.FlutterFragment

class LivekitDemoFragment : FlutterFragment() {
    companion object {
        @JvmStatic
        fun create(options: LivekitDemoOptions): LivekitDemoFragment =
            NewEngineFragmentBuilder(LivekitDemoFragment::class.java)
                .dartEntrypointArgs(
                    listOf(
                        "--serverUrl", options.serverUrl,
                        "--room", options.room,
                        "--name", options.name
                    )
                ).build()
    }
}