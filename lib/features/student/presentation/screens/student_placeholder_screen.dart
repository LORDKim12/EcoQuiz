import 'package:flutter/material.dart';

class StudentPlaceholderScreen extends StatelessWidget {
  const StudentPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modo Alumno')),
      body: const Center(
        child: Text('¡Bienvenido al Mapa de EcoQuiz!'),
      ),
    );
  }
}
