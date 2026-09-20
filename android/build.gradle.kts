allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Modern fix for legacy plugins (like telephony) without using afterEvaluate
subprojects {
    val project = this
    
    // 1. Set namespace if missing using the plugins listener
    listOf("com.android.application", "com.android.library").forEach { pluginId ->
        project.plugins.withId(pluginId) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                try {
                    val getNamespace = android.javaClass.getMethod("getNamespace")
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    if (getNamespace.invoke(android) == null) {
                        setNamespace.invoke(android, "com.${project.name.replace("-", ".")}")
                    }
                } catch (e: Exception) {}
            }
        }
    }

    // 2. Programmatically strip the 'package' attribute from library manifests to satisfy AGP 8+
    project.plugins.withId("com.android.library") {
        project.tasks.withType<com.android.build.gradle.tasks.ProcessLibraryManifest>().configureEach {
            doFirst {
                val manifestFile = mainManifest.get().asFile
                if (manifestFile.exists()) {
                    val content = manifestFile.readText()
                    if (content.contains("package=\"")) {
                        val newContent = content.replace(Regex("""package="[^"]*""""), "")
                        manifestFile.writeText(newContent)
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
