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

// Configure Java toolchain to use Java 21 for all subprojects that apply the Java plugin.
subprojects {
    plugins.withId("java") {
        extensions.configure(org.gradle.api.plugins.JavaPluginExtension::class.java) {
            toolchain.languageVersion.set(org.gradle.jvm.toolchain.JavaLanguageVersion.of(21))
        }
    }

    // Ensure JavaCompile tasks target Java 21 if present.
    tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
        options.release.set(21)
    }
}
