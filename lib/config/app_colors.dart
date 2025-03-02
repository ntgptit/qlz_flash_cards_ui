// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

sealed class AppColors {
  const AppColors._();

  // Brand Colors
  static const primary = Color(0xFF4255FF); // Quizlet blue
  // static const secondary = Color(0xFFFFCD1F); // Yellow
  static const secondary = Color( 
      0xFFCFD8DC); // Softer, muted yellow for better dark theme compatibility

  // Status Colors
  static const success = Color(0xFF2ECC71); // Green
  static const error = Color(0xFFE74C3C); // Red
  static const warning = Color(0xFFFFB800); // Warning yellow

  // Dark Theme Colors
  static const darkBackground = Color(0xFF0A092D); // Navy background
  static const darkSurface = Color(0xFF12113A); // Dark surface
  static const darkCard = Color(0xFF1A1D3D); // Dark card
  static const darkText = Color(0xFFFFFFFF); // White text
  static const darkTextSecondary = Color(0xFF939BB4); // Secondary text
  static const darkBorder = Color(0xFF2C2D4A); // Dark border

  // Light Theme Colors
  static const lightBackground = Color(0xFFFFFFFF); // White background
  static const lightSurface = Color(0xFFF6F7FB); // Light surface
  static const lightText = Color(0xFF1A1D28); // Dark text
  static const lightTextSecondary = Color(0xFF939BB4); // Secondary text
  static const lightBorder = Color(0xFFEBEDF5); // Light border
}
