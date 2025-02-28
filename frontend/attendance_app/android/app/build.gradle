plugins {
<<<<<<< HEAD:frontend/attendance_app/android/app/build.gradle.kts
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin
=======
    id "com.android.application"
    id "kotlin-android"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id "dev.flutter.flutter-gradle-plugin"
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a:frontend/attendance_app/android/app/build.gradle
}

android {
    namespace = "com.example.attendance_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Updated NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.example.attendance_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD:frontend/attendance_app/android/app/build.gradle.kts
            signingConfig = signingConfigs.getByName("debug")
=======
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.debug
>>>>>>> 697e1adc92334cfc53c04454617885398f909b3a:frontend/attendance_app/android/app/build.gradle
        }
    }
}

flutter {
    source = "../.."
}
