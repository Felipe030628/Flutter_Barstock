import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta "speakeasy": fondo casi negro cálido con acentos de latón/oro,
/// inspirada en la barra, las etiquetas de licor y las libretas de cuentas
/// del proyecto web original (Vista/Css/Panel.css y Global.css).
class AppColors {
  static const void_ = Color(0xFF0A0807);
  static const panel = Color(0xFF15100D);
  static const panelAlt = Color(0xFF1D1611);
  static const panelLine = Color(0x33C9A24D);
  static const gold = Color(0xFFC9A24D);
  static const goldSoft = Color(0xFFE6C789);
  static const goldDeep = Color(0xFF8C6D2F);
  static const ink = Color(0xFFF2EFEA);
  static const inkMuted = Color(0xFFAFA79C);
  static const danger = Color(0xFFE0654D);
  static const success = Color(0xFF9CAE6B);
}

class AppTheme {
  // Inter para texto de datos/UI; Playfair Display (serif de "carta de bar")
  // reservado para títulos, con moderación, como pieza distintiva del diseño.
  static final TextTheme _textTheme =
      GoogleFonts.interTextTheme(
    ThemeData(useMaterial3: true, brightness: Brightness.dark).textTheme,
  ).copyWith(
    displayLarge: GoogleFonts.playfairDisplay(fontSize: 38, fontWeight: FontWeight.w700),
    displayMedium: GoogleFonts.playfairDisplay(fontSize: 30, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.playfairDisplay(fontSize: 21, fontWeight: FontWeight.w600, letterSpacing: 0.2),
  ).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  ).copyWith(
    titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
    bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.inkMuted),
    labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkMuted, letterSpacing: 1.1),
  );

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.void_,
      textTheme: _textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.void_,
        secondary: AppColors.goldSoft,
        surface: AppColors.panel,
        onSurface: AppColors.ink,
        error: AppColors.danger,
        onError: AppColors.void_,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.void_,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.gold),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: AppColors.ink,
          fontSize: 21,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panelAlt,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.panelLine),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.panelLine, thickness: 1, space: 32),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.gold,
        selectionColor: Color(0x55C9A24D),
        selectionHandleColor: AppColors.gold,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panelAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        hintStyle: GoogleFonts.inter(color: AppColors.inkMuted, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: AppColors.inkMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.panelLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.panelLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.void_,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.inkMuted,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.panelAlt,
        contentTextStyle: GoogleFonts.inter(color: AppColors.ink),
        actionTextColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.panelLine),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.panel,
      ),
      splashColor: Color(0x14C9A24D),
      highlightColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.gold),
      listTileTheme: const ListTileThemeData(iconColor: AppColors.gold, textColor: AppColors.ink),
    );
  }
}
