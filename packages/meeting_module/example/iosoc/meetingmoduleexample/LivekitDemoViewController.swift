import Flutter
import FlutterPluginRegistrant

@objc public class LivekitDemoViewController: FlutterViewController {
    private let serverUrl: String
    private let room: String
    private let name: String
    
    @objc public init(serverUrl: String, room: String, name: String) {
        self.serverUrl = serverUrl
        self.room = room
        self.name = name
        
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
        fatalError("init(coder:) has not been implemented")
    }
}
