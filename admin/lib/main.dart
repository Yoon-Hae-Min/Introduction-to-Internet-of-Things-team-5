import 'package:flutter/material.dart';
import 'ScanScreen/scan_main.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AppBar(
                centerTitle: true,
                title: const Text(
                  "Admin",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                backgroundColor: Colors.blueGrey.shade300,
              ),
            ),
            body: const ScanScreen()));
  }
}
