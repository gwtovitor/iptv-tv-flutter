import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iptv_flutter_app/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const Loginpage());
  });
}
