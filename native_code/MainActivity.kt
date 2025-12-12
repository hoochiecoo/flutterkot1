package com.bowlmates.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.MediaStore
import android.widget.Toast

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.bowlmates.app/camera"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "openCamera") {
                try {
                    val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                    // В Android 11+ без <queries> resolveActivity вернет null
                    // Поэтому просто пытаемся запустить try-catch блоком
                    startActivity(takePictureIntent)
                    result.success("Launched")
                } catch (e: Exception) {
                    Toast.makeText(context, "Не удалось найти камеру", Toast.LENGTH_LONG).show()
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
