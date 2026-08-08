import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")

    // Flutter Gradle Plugin অবশ্যই Android ও Kotlin plugin-এর পরে থাকবে
    id("dev.flutter.flutter-gradle-plugin")

    // Firebase / Google Services
    id("com.google.gms.google-services")
}

// android/key.properties থেকে signing information load করবে
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.novatechsoft.nova_live"
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
        applicationId = "com.novatechsoft.nova_live"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String

                storeFile = keystoreProperties["storeFile"]?.let {
                    file(it as String)
                }

                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }



    buildTypes {
        release {
            // এখন release build আর debug key ব্যবহার করবে না
            signingConfig = signingConfigs.getByName("release")
        }
    }
}


flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.0.0"))
}