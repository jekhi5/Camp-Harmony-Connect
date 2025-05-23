import 'package:flutter/material.dart';
import 'check_in_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camp Harmony',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(1, 237, 181, 114)),
        useMaterial3: true,
      ),
      home: const CheckInPage(title: 'Camp Harmony'),
    );
  }
}
