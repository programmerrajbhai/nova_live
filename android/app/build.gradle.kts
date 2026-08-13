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

        // 🔥 এই লাইনটি যুক্ত করুন (শুধু ইংরেজি ও বাংলা সাপোর্ট রাখবে)
        resourceConfigurations.addAll(listOf("en", "bn"))




    }



    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")


            isMinifyEnabled = true // 🔥 অব্যবহৃত কোড রিমুভ করবে
            isShrinkResources = true // 🔥 অব্যবহৃত ছবি বা রিসোর্স রিমুভ করবে


        }


    }




}


flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.0.0"))
}