import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для MethodChannel
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CameraWebView(),
  ));
}

class CameraWebView extends StatefulWidget {
  const CameraWebView({super.key});

  @override
  State<CameraWebView> createState() => _CameraWebViewState();
}

class _CameraWebViewState extends State<CameraWebView> {
  late final WebViewController controller;
  
  // КАНАЛ СВЯЗИ С KOTLIN
  // Имя должно совпадать с тем, что в MainActivity.kt
  static const platform = MethodChannel('com.bowlmates.app/camera');

  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..addJavaScriptChannel(
        'BowlmatesApp',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'OPEN_CAMERA') {
            _openNativeCamera();
          }
        },
      )
      ..loadHtmlString('''<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body{background:#000;color:white;display:flex;flex-direction:column;justify-content:center;align-items:center;height:100vh;margin:0;font-family:sans-serif}
.cam-btn{width:80px;height:80px;border-radius:50%;background:#fff;border:4px solid #aaa;display:flex;align-items:center;justify-content:center;cursor:pointer}
.lens{width:60px;height:60px;background:#000;border-radius:50%}
</style>
</head>
<body>
<h2>Native Camera</h2>
<div class="cam-btn" onclick="snap()"><div class="lens"></div></div>
<p>Нажмите для фото</p>
<script>
function snap(){
 if(window.BowlmatesApp) window.BowlmatesApp.postMessage("OPEN_CAMERA");
 else alert("Not in App");
}
</script>
</body>
</html>''');
  }

  // Вызов нативного кода
  Future<void> _openNativeCamera() async {
    try {
      // Показываем юзеру, что процесс пошел
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Запуск нативной камеры Android...')),
      );
      
      // Вызываем метод "openCamera" в Kotlin
      await platform.invokeMethod('openCamera');
      
    } on PlatformException catch (e) {
      debugPrint("Ошибка запуска камеры: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
