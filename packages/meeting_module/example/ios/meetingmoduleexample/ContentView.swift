//
//  ContentView.swift
//  meetingmoduleexample
//
//  Created by aoeiuv on 2024/10/26.
//

import SwiftUI
import Flutter

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button(action: {
                openFlutterPage()
            }) {
                Text("Hello, world!")
            }
        }
        .padding()
    }
}

// 打开 Flutter 页面的函数
func openFlutterPage() {
    let flutterViewController = FlutterViewController()
    flutterViewController.modalPresentationStyle = .fullScreen // 设置全屏展示
    if let window = UIApplication.shared.windows.first {
        window.rootViewController?.present(flutterViewController, animated: true, completion: nil)
    }
}
#Preview {
    ContentView()
}
