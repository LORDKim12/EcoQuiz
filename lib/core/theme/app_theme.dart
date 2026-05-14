import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // ── Configuración de Google Fonts ──────────────────────────────────
    // En web: las fuentes se descargan por HTTP automáticamente.
    // En móvil nativo: se buscan primero en el bundle de la app.
    // Permitimos siempre la descarga HTTP para que funcione en ambos.
    GoogleFonts.config.allowRuntimeFetching = true;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.studentPrimary),

      // ── Tipografía ────────────────────────────────────────────────────
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.nunito(
          color: AppColors.textBrown,
          fontWeight: FontWeight.w900,
          fontSize: 32,
        ),
        titleLarge: GoogleFonts.nunito(
          color: AppColors.textBrown,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: AppColors.textDark,
          fontSize: 16,
        ),
      ),

      // ── AppBar transparente por defecto ────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      // ── Ajustes visuales por plataforma ───────────────────────────
      // En web: quitar efecto de splash/highlight de Material para
      // que se sienta más nativo como app web.
      splashFactory: kIsWeb ? NoSplash.splashFactory : InkSplash.splashFactory,

      // ── Tooltips legibles ──────────────────────────────────────────
      tooltipTheme: const TooltipThemeData(
        textStyle: TextStyle(fontSize: 14, color: Colors.white),
        decoration: BoxDecoration(
          color: Color(0xFF4A3423),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
