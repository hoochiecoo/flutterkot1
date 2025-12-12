import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // Импорт менеджера прав

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
  static const platform = MethodChannel('com.bowlmates.app/camera');

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF121212))
      ..addJavaScriptChannel(
        'BowlmatesApp',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'OPEN_CAMERA') {
            _checkPermissionsAndOpenCamera();
          }
        },
      )
      ..loadHtmlString('''<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
body{background:#121212;color:white;display:flex;flex-direction:column;justify-content:center;align-items:center;height:100vh;margin:0;font-family:sans-serif}
.cam-btn{width:100px;height:100px;border-radius:20px;background:#2196f3;display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 4px 15px rgba(33,150,243,0.4)}
.cam-icon{font-size:40px}
</style>
</head>
<body>
<h2>Запрос прав + Камера</h2>
<div class="cam-btn" onclick="snap()"><div class="cam-icon">📷</div></div>
<p style="color:#aaa;margin-top:20px">Нажми и разреши доступ</p>
<script>
function snap(){
 if(window.BowlmatesApp) window.BowlmatesApp.postMessage("OPEN_CAMERA");
 else alert("Not in App");
}
</script>
</body>
</html>''');
  }

  // 1. Проверяем права -> 2. Вызываем Kotlin
  Future<void> _checkPermissionsAndOpenCamera() async {
    // Запрашиваем право на камеру
    var status = await Permission.camera.request();

    if (status.isGranted) {
      // Если дали добро - вызываем нативный код
      _openNativeCamera();
    } else if (status.isPermanentlyDenied) {
      // Если пользователь навсегда запретил - отправляем в настройки
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нужно разрешение на камеру. Откройте настройки.')),
        );
        openAppSettings();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Доступ к камере отклонен')),
        );
      }
    }
  }

  Future<void> _openNativeCamera() async {
    try {
      await platform.invokeMethod('openCamera');
    } on PlatformException catch (e) {
      debugPrint("Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(child: WebViewWidget(controller: controller)),
    );
  }
}
