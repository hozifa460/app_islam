import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}

fun signingValue(environmentName: String, propertyName: String, fallback: String = ""): String {
    return System.getenv(environmentName)?.takeIf { it.isNotBlank() }
        ?: keystoreProperties.getProperty(propertyName)?.takeIf { it.isNotBlank() }
        ?: fallback
}

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.appislam"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = signingValue("KEY_ALIAS", "keyAlias", "appislam")
            keyPassword = signingValue("KEY_PASSWORD", "keyPassword")
            storeFile = file(signingValue("KEYSTORE_PATH", "storeFile", "release-key.jks"))
            storePassword = signingValue("STORE_PASSWORD", "storePassword")
        }
    }

    defaultConfig {
        applicationId = "com.example.appislam"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}


dependencies {
    // Flutter's deferred-component hooks reference Play Feature Delivery.
    // Use the current split library so it remains compatible with Firebase
    // Integrity's Play Core Common dependency.
    implementation("com.google.android.play:feature-delivery:2.1.0")
    // ✅ 2. أضف هذه المكتبة في قسم dependencies
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
