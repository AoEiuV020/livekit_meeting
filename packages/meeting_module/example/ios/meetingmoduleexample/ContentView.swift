//
//  ContentView.swift
//  meetingmoduleexample
//
//  Created by aoeiuv on 2024/10/26.
//

import SwiftUI
import Flutter
import FlutterPluginRegistrant

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Button(action: {
                openObjectiveCPage()
            }) {
                Text("start object c")
            }
            Button(action: {
                openFlutterPage()
            }) {
                Text("start flutter")
            }
        }
        .padding()
    }
}

// 跳转到 Objective-C 页面
func openObjectiveCPage() {
    let myObjectiveCViewController = MyObjectiveCViewController()
    myObjectiveCViewController.modalPresentationStyle = .fullScreen // 设置全屏展示
    if let window = UIApplication.shared.windows.first {
        window.rootViewController?.present(myObjectiveCViewController, animated: true, completion: nil)
    }
}
// 打开 Flutter 页面的函数
func openFlutterPage() {
    let flutterEngine = FlutterEngine(name: "my flutter engine")
    flutterEngine.run()
    GeneratedPluginRegistrant.register(with: flutterEngine)
    let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
    flutterViewController.modalPresentationStyle = .fullScreen // 设置全屏展示
    if let window = UIApplication.shared.windows.first {
        window.rootViewController?.present(flutterViewController, animated: true, completion: nil)
    }
}
#Preview {
    ContentView()
}
