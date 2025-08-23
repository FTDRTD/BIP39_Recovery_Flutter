import 'package:flutter/material.dart';
import 'package:bip39_recovery_flutter/bip39_recovery/bip39_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIP39 Recovery Tool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Bip39RecoveryScreen(),
    );
  }
}
