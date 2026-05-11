import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

import 'features/student/domain/models/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameState.instance.init();
  runApp(const EcoQuizApp());
}

class EcoQuizApp extends StatelessWidget {
  const EcoQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoQuiz',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: ClipRRect(
              // Si se desea esquinas redondeadas en web
              // borderRadius: BorderRadius.circular(0),
              child: child,
            ),
          ),
        );
      },
      home: const HomeScreen(),
    );
  }
}
