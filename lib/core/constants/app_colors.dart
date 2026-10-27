import 'package:flutter/material.dart';

class AppColors {
  // Haute Joaillerie Luxury Palette (from reference design)
  static const Color background = Color(0xFFFAF7F2);      // Warm Cream / Ivory Background
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Midnight Velvet Navy (Jewel Box Card)
  static const Color cardDarkNavyStart = Color(0xFF0C182B); // Deep Navy Gradient Start
  static const Color cardDarkNavyEnd = Color(0xFF060D18);   // Darker Navy Gradient End
  static const Color midnightOnyx = Color(0xFF09121F);
  static const Color primary = Color(0xFF0C2340);
  static const Color primaryDark = Color(0xFF09121F);
  static const Color primaryLight = Color(0xFF1B3B6F);

  // Pure Precious Theme Accent (#73ABDB)
  static const Color champagneGold = Color(0xFF73ABDB);   // Main Theme Blue (#73ABDB)
  static const Color richGold = Color(0xFF73ABDB);        // Rich Theme Blue (#73ABDB)
  static const Color brightGold = Color(0xFF73ABDB);      // Radiant Polished Theme Blue (#73ABDB)
  static const Color goldLight = Color(0xFFEFF7FC);       // Soft Blue Tint
  static const Color warmGoldTint = Color(0xFFEFF7FC);    // Soft Blue Tint
  static const Color goldBorder = Color(0x7773ABDB);      // Delicate Blue Border
  static const Color sealGold = Color(0xFF73ABDB);

  // Accents
  static const Color roseGold = Color(0xFFC84B66);
  static const Color accent = Color(0xFF73ABDB);           // Primary Accent (#73ABDB)
  static const Color accentLight = Color(0xFFEFF7FC);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF121926);     // Dark Obsidian
  static const Color textSecondary = Color(0xFF64748B);   // Slate Grey
  static const Color textMuted = Color(0xFF94A3B8);       // Muted
  static const Color textGold = Color(0xFF73ABDB);        // Theme Blue text for price & certs
  static const Color textLightGold = Color(0xFFD6EAF8);

  // Borders & Ambient Shadows
  static const Color border = Color(0xFFE8E0D2);          // Warm Pearl Border
  static const Color borderLight = Color(0xFFF2ECE1);
  static const Color cardShadow = Color(0x120C2340);

  // Velvet Pedestal Display
  static const Color velvetPedestal = Color(0xFF152238);
  static const Color pedestalLighting = Color(0xFF1B2E4D);

  // Action Accents
  static const Color whatsapp = Color(0xFF25D366);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFE11D48);

  static const Map<String, Color> colorNameToColor = {
    'Blue': Color(0xFF0D47A1),
    'Green': Color(0xFF1B5E20),
    'Yellow': Color(0xFFE5A910),
    'Pink': Color(0xFFD81B60),
    'Purple': Color(0xFF6A1B9A),
    'Red': Color(0xFFB71C1C),
    'Orange': Color(0xFFE65100),
    'Black': Color(0xFF1A1A1A),
    'Brown': Color(0xFF4E342E),
    'White': Color(0xFFCFD8DC),
  };
}
