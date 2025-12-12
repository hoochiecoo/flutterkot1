package com.bowlmates.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.MediaStore
import android.widget.Toast

class MainActivity: FlutterActivity() {
    // Имя канала (должно совпадать с Dart)
    private val CHANNEL = "com.bowlmates.app/camera"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "openCamera") {
                // ЛОГИКА ЗАПУСКА КАМЕРЫ
                try {
                    val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                    // Проверяем, есть ли приложение камеры (для Android < 11 или если есть queries)
                    if (takePictureIntent.resolveActivity(packageManager) != null) {
                        startActivity(takePictureIntent)
                        result.success("Camera Opened")
                    } else {
                        // Пытаемся запустить даже если проверка не прошла (часто работает на современных ОС)
                        startActivity(takePictureIntent)
                        result.success("Force Opened")
                    }
                } catch (e: Exception) {
                    Toast.makeText(context, "Error launching camera", Toast.LENGTH_SHORT).show()
                    result.error("UNAVAILABLE", "Camera not available", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
