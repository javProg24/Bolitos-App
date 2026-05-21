import 'package:flutter/material.dart';
import 'package:frontend/pages/page_login.dart';

void main() {
  runApp(const BolitosApp());
}

class BolitosApp extends StatelessWidget {
  const BolitosApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bolitos App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFFFF7ED),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF97316)),
      ),
      initialRoute: '/',
      routes: {'/': (_) => const LoginPage()},
    );
  }
}
