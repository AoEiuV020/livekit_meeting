package com.aoeiuv020.meeting_flutter

import android.util.Base64
import com.aoeiuv020.meeting_flutter.util.JsonUtil
import io.flutter.embedding.android.FlutterFragment

class LivekitDemoFragment : FlutterFragment() {
    companion object {
        @JvmStatic
        fun create(options: LivekitDemoOptions): LivekitDemoFragment =
            NewEngineFragmentBuilder(LivekitDemoFragment::class.java)
                .dartEntrypointArgs(
                    listOf(
                        "--livekitDemoOptions",
                        Base64.encodeToString(
                            JsonUtil.toJson(options).toByteArray(),
                            Base64.NO_WRAP
                        )
                    )
                ).build()
    }
}