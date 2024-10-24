@file:Suppress("unused")

package com.aoeiuv020.meeting_flutter

import android.content.Context
import io.flutter.embedding.android.FlutterFragmentActivity

class LivekitDemoFragmentActivity : FlutterFragmentActivity() {
    companion object {
        @JvmStatic
        fun start(context: Context, options: LivekitDemoOptions) {
            NewEngineIntentBuilder(
                LivekitDemoFragmentActivity::class.java,
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