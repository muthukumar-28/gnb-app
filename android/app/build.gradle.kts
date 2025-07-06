// Module-level build.gradle.kts (android/app)

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.gnbapp.mock"
    compileSdk = 35
    ndkVersion = "29.0.13599879"

    defaultConfig {
        applicationId = "com.gnbapp.mock"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Replace for production
        }
    }
}

flutter {
    source = "../.."
}
