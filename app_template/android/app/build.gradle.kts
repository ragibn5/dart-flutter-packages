import com.android.build.api.dsl.SigningConfig
import org.jetbrains.kotlin.konan.properties.loadProperties
import java.util.Properties

plugins {
    id("com.android.application")

    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration

    id("kotlin-android")

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ragibn5.fat"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // TODO: Specify/Change your own unique Application ID
        //  (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ragibn5.fat"

        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        // Define version name and code.
        // It is not always possible to maintain same version name and version code
        // for all the platforms. Thus, it is better to maintain independent version
        // name & code for each platform.
        versionCode = 1
        versionName = "0.0.1"
    }

    signingConfigs {
        create("release") {
            // Assuming the property file is present at the given path
            configureSigningConfig(
                this,
                loadProperties("key.properties")
            )
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug key, so that `flutter run --release` works.
            // If we need to override the key for a specific flavor, for example for prodRelease,
            // we should do that inside that specific flavor's block, which is in turn, under the
            // `productFlavors` block.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    flavorDimensions += "default"
    productFlavors {
        // For Developers
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-DEV"
        }
        // For QA & Testers
        create("exp") {
            dimension = "default"
            applicationIdSuffix = ".exp"
            versionNameSuffix = "-EXP"
        }
        // For final testing (PMs and Clients)
        create("stage") {
            dimension = "default"
            applicationIdSuffix = ".stage"
            versionNameSuffix = "-STAGE"
        }
        // For End-Users
        create("prod") {
            dimension = "default"
            applicationIdSuffix = ""
            versionNameSuffix = ""
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
    target = project.getDartEntrypoint()
}

fun configureSigningConfig(config: SigningConfig, props: Properties) {
    config.apply {
        keyAlias = props["keyAlias"]?.toString()
        keyPassword = props["keyPassword"]?.toString()
        storeFile = props["storeFile"]?.let { file(it.toString()) }
        storePassword = props["storePassword"]?.toString()
    }
}

fun Project.getDartEntrypoint(): String {
    val flavor = extractFlavorName()
    return "lib/main_$flavor.dart"
}

fun Project.extractFlavorName(): String {
    val dev = "dev"
    val exp = "exp"
    val stage = "stage"
    val prod = "prod"
    val tasks = gradle.startParameter.taskNames.joinToString(" ").lowercase()

    // Values added here MUST match the actual flavor names of the app.
    // Also, make sure to add/remove the entry here if you add/remove any flavor.
    // For example, if you add a new flavor, say `xyz`, you must add it to the
    // list below.
    val flavors = listOf(dev, exp, stage, prod)

    flavors.forEach { flavor ->
        if (tasks.contains(flavor)) return flavor
    }

    // fallback
    return dev
}