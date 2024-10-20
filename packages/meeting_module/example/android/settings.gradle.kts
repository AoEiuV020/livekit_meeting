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
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
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
