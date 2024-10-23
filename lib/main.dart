import 'package:flutter/material.dart';
import 'package:absensi/page/login_page.dart';

void main() {
  runApp(Absensi());
}

class Absensi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
