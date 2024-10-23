package com.aoeiuv020.meetingmoduleexample

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.aoeiuv020.meeting_flutter.MeetingActivity
import com.aoeiuv020.meeting_flutter.MeetingFragmentActivity
import com.aoeiuv020.meeting_flutter.MeetingOptions
import com.aoeiuv020.meetingmoduleexample.ui.theme.MeetingModuleExampleTheme
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MeetingModuleExampleTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Box(
                        modifier = Modifier.fillMaxSize()
                    ) {
                        Connect(
                            modifier = Modifier
                                .padding(innerPadding)
                                .align(Alignment.Center)
                        )
                    }
                }
            }
        }
    }
}

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "settings")

@Composable
fun Connect(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var serverUrl by remember { mutableStateOf("") }
    var room by remember { mutableStateOf("") }
    var name by remember { mutableStateOf("") }

    // 从DataStore中加载保存的输入
    LaunchedEffect(key1 = true) {
        val preferences = context.dataStore.data.first()
        serverUrl = preferences[stringPreferencesKey("serverUrl")] ?: ""
        room = preferences[stringPreferencesKey("room")] ?: ""
        name = preferences[stringPreferencesKey("name")] ?: ""
    }

    Column(
        modifier = modifier
    ) {
        TextField(
            value = serverUrl,
            onValueChange = { serverUrl = it },
            label = { Text("Server URL") }
        )
        TextField(
            value = room,
            onValueChange = { room = it },
            label = { Text("Room") }
        )
        TextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Name") }
        )
        Button(
            onClick = {
                // 保存输入到DataStore
                scope.launch {
                    context.dataStore.edit { settings ->
                        settings[stringPreferencesKey("serverUrl")] = serverUrl
                        settings[stringPreferencesKey("room")] = room
                        settings[stringPreferencesKey("name")] = name
                    }
                }
                MeetingActivity.start(context, MeetingOptions(serverUrl, room, name))
            }
        ) {
            Text("CONNECT")
        }
    }
}
