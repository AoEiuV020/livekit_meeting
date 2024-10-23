package com.aoeiuv020.meeting_flutter

import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity

class MeetingFragmentActivity : FlutterFragmentActivity() {
    companion object {
        @JvmStatic
        fun start(context: Context, options: MeetingOptions) {
            NewEngineIntentBuilder(
                MeetingFragmentActivity::class.java,
            ).dartEntrypointArgs(
                listOf(
                    "--serverUrl", options.serverUrl,
                    "--room", options.room,
                    "--name", options.name
                )
            ).build(context).also {
                context.startActivity(it)
            }
        }
    }

}