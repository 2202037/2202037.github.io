import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Deep Green (Healthcare)
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryContainer = Color(0xFFE8F5E9);

  // Secondary - Light Green
  static const Color secondary = Color(0xFF81C784);
  static const Color secondaryLight = Color(0xFFA5D6A7);
  static const Color secondaryDark = Color(0xFF388E3C);

  // Accent
  static const Color accent = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFF1DE9B6);

  // Background
  static const Color background = Color(0xFFF8FFF8);
  static const Color surface = Colors.white;
  static const Color inputFill = Color(0xFFF5F5F5);
  static const Color chipBackground = Color(0xFFE8F5E9);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFADB5BD);

  // Status
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color success = Color(0xFF43A047);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color info = Color(0xFF1E88E5);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Blood Bank
  static const Color bloodRed = Color(0xFFD32F2F);
  static const Color bloodRedLight = Color(0xFFFFCDD2);
  static const Color bloodAvailable = Color(0xFF2E7D32);
  static const Color bloodCritical = Color(0xFFE53935);
  static const Color bloodModerate = Color(0xFFFF9800);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);

  // Shadow
  static const Color shadow = Color(0x1A2E7D32);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient healthGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF00796B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Quick Action Colors
  static const Color doctorActionColor = Color(0xFF1565C0);
  static const Color bloodActionColor = Color(0xFFB71C1C);
  static const Color clinicActionColor = Color(0xFF6A1B9A);
  static const Color pharmacyActionColor = Color(0xFFE65100);
}
