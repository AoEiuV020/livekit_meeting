//
//  ContentView.swift
//  meetingmoduleexample
//
//  Created by aoeiuv on 2024/10/26.
//

import SwiftUI
import Flutter
import FlutterPluginRegistrant

struct ConnectionInfo: Codable {
    var serverUrl: String
    var room: String
    var name: String
}

struct InputField: View {
    var label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            TextField("Enter \(label.lowercased())", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.vertical, 5)
    }
}

struct ContentView: View {
    @AppStorage("serverUrl") private var serverUrl = "https://meet.livekit.io"
    @AppStorage("room") private var room = "123456"
    @AppStorage("name") private var name = "ios"
 
    @State private var inputServerUrl = ""
    @State private var inputRoom = ""
    @State private var inputName = ""
    var body: some View {
        VStack(spacing: 20) {
            InputField(label: "Server URL", text: $inputServerUrl)
            InputField(label: "Room", text: $inputRoom)
            InputField(label: "Name", text: $inputName)
            
            Button(action: {
                saveConnectionInfo()
                openFlutterPage()
            }) {
                Text("Connect")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 20)
            Button(action: {
                openObjectiveCPage()
            }) {
                Text("start object c")
            }
        }
        .padding()
        .onAppear(perform: loadConnectionInfo) // 视图初始化时加载已保存的数据
    }
    
    private func saveConnectionInfo() {
        // 保存到 AppStorage
        serverUrl = inputServerUrl
        room = inputRoom
        name = inputName
    }
    
    private func loadConnectionInfo() {
        // 从 AppStorage 中加载
        inputServerUrl = serverUrl
        inputRoom = room
        inputName = name
    }
    // 跳转到 Objective-C 页面
    private func openObjectiveCPage() {
        let vc = MyObjectiveCViewController()
        vc.modalPresentationStyle = .fullScreen // 设置全屏展示
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
    // 打开 Flutter 页面的函数
    private func openFlutterPage() {
        let vc = LivekitDemoViewController(serverUrl: inputServerUrl, room: inputRoom, name: inputName)
        vc.modalPresentationStyle = .fullScreen // 设置全屏展示
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(vc, animated: true, completion: nil)
        }
    }
}

#Preview {
    ContentView()
}
