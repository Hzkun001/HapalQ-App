import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const HafalQApp());
}

class HafalQApp extends StatelessWidget {
  const HafalQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HafalQ',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
      home: const HomeScreen(), // Halaman pertama saat aplikasi dibuka
    );
  }
}
