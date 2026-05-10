import 'package:flutter/material.dart';

class TeacherPlaceholderScreen extends StatelessWidget {
  const TeacherPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Maestro')),
      body: const Center(
        child: Text('Dashboard del Maestro (Requiere PIN)'),
      ),
    );
  }
}
