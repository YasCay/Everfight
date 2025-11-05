allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Configure Java toolchain to use Java 17 for all subprojects that apply the Java plugin.
subprojects {
    plugins.withId("java") {
        extensions.configure(org.gradle.api.plugins.JavaPluginExtension::class.java) {
            toolchain.languageVersion.set(org.gradle.jvm.toolchain.JavaLanguageVersion.of(17))
        }
    }

    // Ensure JavaCompile tasks target Java 17 if present.
    // NOTE: Setting the `--release` option breaks Android Gradle Plugin's bootclasspath setup
    // for Android modules. Only set `options.release` for pure Java projects (non-Android).
    tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
        if (!(project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library"))) {
            options.release.set(17)
        } else {
            // Android modules use `compileOptions` / Java toolchain configured in their android block.
        }
    }
}
