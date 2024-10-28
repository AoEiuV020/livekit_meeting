package com.aoeiuv020.meeting_flutter

import android.annotation.SuppressLint
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.FragmentManager
import com.aoeiuv020.meetingmoduleexample.R

@SuppressLint("MissingSuperCall")
class LivekitDemoActivity : AppCompatActivity() {
    private val TAG_FLUTTER_FRAGMENT = "flutter_fragment"
    private lateinit var options: LivekitDemoOptions
    private lateinit var fragment: LivekitDemoFragment

    companion object {
        @JvmStatic
        fun start(context: Context, options: LivekitDemoOptions) {
            val starter = Intent(context, LivekitDemoActivity::class.java)
                .putExtra("options", options)
            context.startActivity(starter)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_meeting)
        initArgs()
        initFragment()
        fragment.postOnChannelReady {
            initEvent()
        }
    }

    private fun initEvent() {
        fragment.interceptHangup(::interceptHangup)
    }

    private fun interceptHangup(): Boolean {
        AlertDialog.Builder(this)
            .setTitle("确认挂断")
            .setMessage("确定离开当前会议吗？")
            .setPositiveButton("是") { dialog, _ ->
                fragment.hangup()
                dialog.dismiss()
            }
            .setNegativeButton("否") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
        return true
    }

    private fun initArgs() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            options = intent.getSerializableExtra("options", LivekitDemoOptions::class.java)!!
        } else {
            @Suppress("DEPRECATION")
            options = intent.getSerializableExtra("options") as LivekitDemoOptions
        }
    }

    private fun initFragment() {
        val fragmentManager: FragmentManager = supportFragmentManager

        val existsFragment = fragmentManager
            .findFragmentByTag(TAG_FLUTTER_FRAGMENT) as LivekitDemoFragment?

        if (existsFragment == null) {
            val newFlutterFragment = LivekitDemoFragment.create(options)
            fragment = newFlutterFragment
            fragmentManager
                .beginTransaction()
                .add(
                    R.id.flFragment,
                    newFlutterFragment,
                    TAG_FLUTTER_FRAGMENT
                )
                .commit()
        } else {
            fragment = existsFragment
        }
    }


    override fun onPostResume() {
        super.onPostResume()
        fragment.onPostResume()
    }

    override fun onNewIntent(intent: Intent) {
        fragment.onNewIntent(intent)
    }

    override fun onBackPressed() {
        // 文档里有这个方法传递， 但FlutterFragmentActivity居然没有这个，
        // 这玩意儿居然是单独有一个参数控制的， shouldAutomaticallyHandleOnBackPressed，
        fragment.onBackPressed()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        fragment.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)
        fragment.onActivityResult(
            requestCode,
            resultCode,
            data
        )
    }

    override fun onUserLeaveHint() {
        fragment.onUserLeaveHint()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        fragment.onTrimMemory(level)
    }
}
