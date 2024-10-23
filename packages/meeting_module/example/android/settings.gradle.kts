pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    val storageUrl = System.getenv("FLUTTER_STORAGE_BASE_URL") ?: "https://storage.googleapis.com"
    repositories {
        maven(rootDir.resolve("../../build/host/outputs/repo"))
        maven("$storageUrl/download.flutter.io")
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

rootProject.name = "MeetingModuleExample"
include(":app")


apply("./gradle/props.gradle.kts")
apply("./gradle/project.gradle.kts")

gradle.extra.properties.toSortedMap().forEach { (key, value) ->
    println("$key => $value")
}

findProject(":flutter")?.let {
    val flutterSdkPath = gradle.extra["flutter.sdk"]
    assert(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
    apply("$flutterSdkPath/packages/flutter_tools/gradle/module_plugin_loader.gradle")
}