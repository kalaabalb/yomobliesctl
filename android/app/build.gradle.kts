import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

val releaseBuildRequested =
    gradle.startParameter.taskNames.any { taskName ->
        taskName.contains("Release", ignoreCase = true)
    }

if (releaseBuildRequested && !keystorePropertiesFile.exists()) {
    throw GradleException(
        "Android release signing is not configured. Copy android/key.properties.example to android/key.properties " +
            "and point storeFile to a local release keystore before building release artifacts.",
    )
}

android {
    namespace = "com.yomobiles.admin"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.yomobiles.admin"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storeFilePath = keystoreProperties["storeFile"]?.toString()?.trim().orEmpty()
                val storePassword = keystoreProperties["storePassword"]?.toString().orEmpty()
                val keyAlias = keystoreProperties["keyAlias"]?.toString().orEmpty()
                val keyPassword = keystoreProperties["keyPassword"]?.toString().orEmpty()

                if (storeFilePath.isBlank() || storePassword.isBlank() || keyAlias.isBlank() || keyPassword.isBlank()) {
                    throw GradleException(
                        "android/key.properties is missing required release signing values. " +
                            "Copy android/key.properties.example and fill in all placeholders.",
                    )
                }

                val storeFile = rootProject.file(storeFilePath)
                if (!storeFile.exists()) {
                    throw GradleException(
                        "Release keystore not found at ${storeFile.absolutePath}. " +
                            "Update android/key.properties to point to a valid local keystore.",
                    )
                }

                this.storeFile = storeFile
                this.storePassword = storePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
