gradle.extra.properties.filter {
    it.key.startsWith("module.") && it.value is String
}.mapValues {
    it.value as String
}.filter {
    it.value.isNotBlank()
}.filter {
    rootDir.resolve(it.value).isDirectory
}.mapKeys {
    it.key.removePrefix("module.")
}.forEach { (key, value) ->
    val path = ":" + key.replace(".", ":")
    include(path)
    project(path).projectDir = rootDir.resolve(value)
}
