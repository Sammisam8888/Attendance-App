plugins {
    id("com.android.application") version "8.1.0" apply false
    id("kotlin-android") version "1.8.10" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
}

android {
    namespace = "com.example.attendance_app"
    compileSdk = 34  // Updated from 35 to 34 for better compatibility

    defaultConfig {
        applicationId = "com.example.attendance_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // Add this section
    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:unchecked")
        options.compilerArgs.add("-Xlint:deprecation")
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.10")
}