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

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Fix missing namespace for old packages like flutter_bluetooth_serial
subprojects {
   val configureFixes = {
    if (project.hasProperty("android")) {
        val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension

        // Fix missing namespace
        if (android.namespace == null) {
            android.namespace = android.defaultConfig.applicationId
                ?: project.group.toString().ifEmpty { "com.placeholder.${project.name}" }
        }
    }
}
    // Fix lStar error: force older androidx.core that doesn't need lStar
    configurations.all {
        resolutionStrategy.eachDependency {
            if (requested.group == "androidx.core") {
                useVersion("1.9.0")
            }
        }
    }

    if (project.state.executed) {
        configureFixes()
    } else {
        project.afterEvaluate { configureFixes() }
    }
}
