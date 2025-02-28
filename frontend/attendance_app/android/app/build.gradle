plugins {
    id 'com.android.application'
    id 'kotlin-android'
}

android {
    compileSdkVersion 30

    defaultConfig {
        applicationId "com.example.attendance_app"
        minSdkVersion 16
        targetSdkVersion 30
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
    implementation 'com.android.support:appcompat-v7:28.0.0'
    implementation 'com.android.support.constraint:constraint-layout:1.1.3'
    implementation 'com.google.firebase:firebase-analytics:17.2.2'
}

apply plugin: 'com.google.gms.google-services'
