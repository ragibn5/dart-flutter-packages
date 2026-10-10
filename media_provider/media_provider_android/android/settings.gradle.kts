pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    // Only consulted when this module is built on its own. As a subproject of a
    // host app the host's settings supply these, and naming versions here would
    // conflict with the versions already on its classpath.
    plugins {
        id("com.android.library") version "8.11.1"
        id("org.jetbrains.kotlin.android") version "2.2.20"
    }
    // The build file asks for the legacy `kotlin-android` id, which no longer
    // resolves on its own. Alias it rather than change the build file, so the
    // same script still works when a host app puts the plugin on the classpath.
    resolutionStrategy {
        eachPlugin {
            if (requested.id.id == "kotlin-android") {
                useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.20")
            }
        }
    }
}

rootProject.name = "media_provider_android"
