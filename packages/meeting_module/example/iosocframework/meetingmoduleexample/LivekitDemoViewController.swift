import UIKit
import Flutter
import FlutterPluginRegistrant

@objcMembers // 使所有属性和方法都可见于 Objective-C
public class LivekitDemoViewController: FlutterViewController {
    // 初始化时接收参数
    public init(serverUrl: String, room: String, name: String) {
        let flutterEngine = FlutterEngine(name: "my flutter engine")
        let entrypointArgs: [String] = [
            "--autoConnect",
            "--serverUrl=" + serverUrl,
            "--room=" + room,
            "--name=" + name,
        ]
        
        flutterEngine.run(withEntrypoint: nil, libraryURI: nil, initialRoute: nil, entrypointArgs: entrypointArgs)
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        super.init(engine: flutterEngine, nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
