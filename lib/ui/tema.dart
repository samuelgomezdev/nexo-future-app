import 'package:flutter/material.dart';

/// Cores do protótipo no Figma (página Design System), com a identidade do HOW IV.
abstract final class CoresNexo {
  static const primaria700 = Color(0xFF002B5C);
  static const primaria500 = Color(0xFF004089);
  static const primaria300 = Color(0xFF5C86C2);
  static const primaria100 = Color(0xFFE3ECF8);
  static const primaria50 = Color(0xFFF2F6FC);
  static const coral = Color(0xFFE5654B);
  static const ambar = Color(0xFFF2B233);
  static const ambarFundo = Color(0xFFFFF4DB);
  static const sucesso = Color(0xFF1B7F4C);
  static const sucessoFundo = Color(0xFFE3F4EA);
  static const alerta = Color(0xFF8A5A00);
  static const alertaFundo = Color(0xFFFFF3D6);
  static const erro = Color(0xFFC00000);
  static const erroFundo = Color(0xFFFDECEC);
  static const neutro900 = Color(0xFF14213D);
  static const neutro700 = Color(0xFF44516B);
  static const neutro500 = Color(0xFF6B7489);
  static const neutro300 = Color(0xFFC9CFDA);
  static const neutro200 = Color(0xFFE4E8EF);
  static const neutro100 = Color(0xFFF4F6F9);
}

ThemeData temaNexo() {
  const cores = ColorScheme(
    brightness: Brightness.light,
    primary: CoresNexo.primaria500,
    onPrimary: Colors.white,
    primaryContainer: CoresNexo.primaria100,
    onPrimaryContainer: CoresNexo.primaria700,
    secondary: CoresNexo.ambar,
    onSecondary: CoresNexo.neutro900,
    secondaryContainer: CoresNexo.ambarFundo,
    onSecondaryContainer: CoresNexo.alerta,
    tertiary: CoresNexo.coral,
    onTertiary: Colors.white,
    error: CoresNexo.erro,
    onError: Colors.white,
    errorContainer: CoresNexo.erroFundo,
    onErrorContainer: CoresNexo.erro,
    surface: Colors.white,
    onSurface: CoresNexo.neutro900,
    onSurfaceVariant: CoresNexo.neutro700,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: CoresNexo.neutro100,
    surfaceContainer: CoresNexo.neutro100,
    surfaceContainerHigh: CoresNexo.neutro200,
    surfaceContainerHighest: CoresNexo.neutro200,
    outline: CoresNexo.neutro300,
    outlineVariant: CoresNexo.neutro200,
  );

  // Estilos de texto do Figma (Título, Corpo, Rótulo, Legenda).
  const textos = TextTheme(
    headlineMedium: TextStyle(
      fontSize: 28,
      height: 34 / 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      height: 28 / 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(fontSize: 15, height: 22 / 15),
    bodyMedium: TextStyle(fontSize: 13, height: 18 / 13),
    labelLarge: TextStyle(
      fontSize: 15,
      height: 20 / 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      height: 18 / 13,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    bodySmall: TextStyle(fontSize: 12, height: 16 / 12),
  );

  final bordaCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: CoresNexo.neutro300),
  );
  final formaBotao = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: cores,
    fontFamily: 'Inter',
    textTheme: textos.apply(
      bodyColor: CoresNexo.neutro900,
      displayColor: CoresNexo.neutro900,
    ),
    scaffoldBackgroundColor: CoresNexo.neutro100,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: CoresNexo.neutro900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CoresNexo.neutro900,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CoresNexo.neutro200),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: bordaCampo,
      enabledBorder: bordaCampo,
      focusedBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: CoresNexo.primaria500, width: 2),
      ),
      errorBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: CoresNexo.erro, width: 2),
      ),
      focusedErrorBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: CoresNexo.erro, width: 2),
      ),
      hintStyle: const TextStyle(color: CoresNexo.neutro500),
      errorStyle: const TextStyle(color: CoresNexo.erro, fontSize: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: formaBotao,
        disabledBackgroundColor: CoresNexo.neutro200,
        disabledForegroundColor: CoresNexo.neutro500,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: formaBotao,
        side: const BorderSide(color: CoresNexo.primaria500, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: const BorderSide(color: CoresNexo.neutro200),
      selectedColor: CoresNexo.primaria500,
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      checkmarkColor: Colors.white,
    ),
  );
}
