import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // Buat HomePage di folder pages

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PinSpace',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1523),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
        ),
      ),

      // ➜ LANGSUNG KE HOMEPAGE
      home: HomePage(),
    );
  }
}
