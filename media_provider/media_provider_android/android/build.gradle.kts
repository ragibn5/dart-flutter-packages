group = "com.ragibn5.media.provider.media_provider_android"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("org.jetbrains.kotlin:kotlin-serialization:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/**
 * True when this module is the root of the build rather than a subproject of a
 * Flutter host app.
 *
 * The two need different wiring: only a standalone build has to supply the
 * Flutter embedding itself. In a host build the app provides it, and adding a
 * second copy fights the host's dependency constraints.
 *
 * `gradle.parent` is null for Flutter's included plugin projects too, so the
 * root project's name is what actually distinguishes the two: a host app is
 * named after the app, never after this plugin.
 */
val isStandaloneBuild: Boolean = rootProject.name == "media_provider_android"

plugins {
    id("com.android.library")
    id("kotlin-android")
}

// Applied the "old way" (see kotlinx.serialization README) so it resolves from the
// buildscript classpath above and shares `kotlinVersion`. A version-less `plugins {}`
// entry isn't found when a host app builds this plugin.
apply(plugin = "kotlinx-serialization")

android {
    namespace = "com.ragibn5.media.provider.media_provider_android"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    // Every public declaration must be marked `public`,
    // so that nothing joins the plugin's API by accident.
    explicitApi()
}

dependencies {
    // A host app puts the Flutter embedding on this module's classpath. A
    // standalone build has no host, so it is resolved from the local Gradle
    // cache instead (see flutterEmbeddingJar below).
    //
    // `compileOnly` for the main source set: the embedding must never end up in
    // a host's runtime classpath, since the host ships its own.
    if (isStandaloneBuild) {
        compileOnly(files(flutterEmbeddingJar()))
        // `VisibleForTesting` on the plugin's `attach`, normally transitive
        // through the embedding.
        compileOnly("androidx.annotation:annotation:1.9.1")
    }

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.9.0")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.10.2")

    // The tests drive the real `MethodChannel`/`BinaryMessenger` types, so the
    // embedding is needed to run them, not merely to compile against.
    if (isStandaloneBuild) {
        testImplementation(files(flutterEmbeddingJar()))
        testImplementation("androidx.annotation:annotation:1.9.1")
    }
}

/**
 * The `io.flutter` embedding jar, resolved from the local Gradle cache.
 *
 * The embedding is not published to Maven Central, and a standalone build has no
 * Flutter host app to provide it, so it is picked out of the cache instead.
 * Honours `GRADLE_USER_HOME`, defaulting to `~/.gradle`.
 */
fun flutterEmbeddingJar(): File {
    val gradleUserHome = System.getenv("GRADLE_USER_HOME")
        ?: "${System.getProperty("user.home")}/.gradle"
    val cache = File(gradleUserHome, "caches/modules-2/files-2.1/io.flutter")
    return cache.walkTopDown()
        .filter { it.isFile && it.name.startsWith("flutter_embedding_debug-") && it.extension == "jar" }
        .filterNot { it.name.endsWith("-sources.jar") }
        .maxByOrNull { it.lastModified() }
        ?: error(
            "No io.flutter embedding jar under $cache. Populate it by building the " +
                "example app once (`flutter build apk` in example/), or run these tests " +
                "through the host: example/android: " +
                "./gradlew :media_provider_android:testDebugUnitTest",
        )
}
