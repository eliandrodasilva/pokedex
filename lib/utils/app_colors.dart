import 'package:flutter/material.dart';

class AppColors {
  // Paleta principal inspirada no universo Pokémon
  static const Color primaryRed = Color(0xFFDC0A2D);
  static const Color darkRed = Color(0xFF8F1E1E);
  static const Color accentBlue = Color(0xFF2B73B9);
  static const Color accentYellow = Color(0xFFFFCB05);

  // Fundos e Neutros
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1E2022);
  static const Color textSecondary = Color(0xFF747476);
  static const Color divider = Color(0xFFE5E7EB);

  // Tipos de Pokémon
  static const Map<String, Color> typeColors = {
    'normal': Color(0xFFA8A878),
    'fire': Color(0xFFF08030),
    'water': Color(0xFF6890F0),
    'grass': Color(0xFF78C850),
    'electric': Color(0xFFF8D030),
    'ice': Color(0xFF98D8D8),
    'fighting': Color(0xFFC03028),
    'poison': Color(0xFFA040A0),
    'ground': Color(0xFFE0C068),
    'flying': Color(0xFFA890F0),
    'psychic': Color(0xFFF85888),
    'bug': Color(0xFFA8B820),
    'rock': Color(0xFFB8A038),
    'ghost': Color(0xFF705898),
    'dragon': Color(0xFF7038F8),
    'steel': Color(0xFFB8B8D0),
    'fairy': Color(0xFFEE99AC),
    'dark': Color(0xFF705746),
  };

  static Color getColorForType(String type) {
    return typeColors[type.toLowerCase()] ?? const Color(0xFF68A090);
  }
}
