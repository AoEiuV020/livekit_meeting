findProject(":flutter")?.let {
    val flutterSdkPath = gradle.extra["flutter.sdk"]
    assert(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
    apply("$flutterSdkPath/packages/flutter_tools/gradle/module_plugin_loader.gradle")
}
