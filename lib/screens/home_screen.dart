import 'package:flutter/material.dart';

/// メイン画面（仮実装）
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aliby'),
      ),
      body: const Center(
        child: Text('Home Screen - 実装予定'),
      ),
    );
  }
}