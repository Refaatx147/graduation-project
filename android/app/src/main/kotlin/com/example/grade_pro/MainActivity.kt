package com.example.grade_pro

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.FirebaseApp
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
      GeneratedPluginRegistrant.registerWith(flutterEngine)
                super.configureFlutterEngine(flutterEngine)

             window.setBackgroundDrawableResource(android.R.color.transparent)


    }
}
