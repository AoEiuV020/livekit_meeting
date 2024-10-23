import java.util.Properties

Properties().also { properties ->
    listOf(
        "gradle.properties",
        "local.properties",
    ).forEach { fileName ->
        rootProject.projectDir.resolve(fileName).takeIf { it.isFile }?.reader()?.use { input ->
            properties.load(input)
        }
    }
}.also { properties ->
    properties.keys.forEach { key ->
        gradle.extra[key.toString()] = properties.getProperty(key.toString())
    }
}