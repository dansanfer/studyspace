import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Fundos & Cards
  static const Color bgPaper = Color(0xFFEEEAE1);        // Fundo geral bege papel
  static const Color cardCream = Color(0xFFF8F5EE);      // Cards claros (Matérias / Rádio)
  static const Color cardPetroleum = Color(0xFF15221F);  // Card principal do Timer
  static const Color navBarDark = Color(0xFF1F2D29);     // Bottom Bar flutuante

  // Textos
  static const Color textDark = Color(0xFF25332E);       // Títulos principais
  static const Color textEyebrow = Color(0xFF84918B);    // Subtítulos em caixa alta
  static const Color textLight = Color(0xFFF5F2EA);      // Números do cronômetro no card escuro
  static const Color textMutedLight = Color(0xFFB3BCB8); // Legendas no card escuro

  // Acentos & Tags
  static const Color terracotta = Color(0xFFE5A06D);     // Destaque principal / Anel do timer
  static const Color terracottaDeep = Color(0xFFB76D4D); // Texto de urgência
  static const Color sageGreen = Color(0xFF78A693);      // Física / Progresso concluído
  static const Color softLilac = Color(0xFFA98BC1);      // Design de Interfaces
  static const Color pillBeige = Color(0xFFEEE9DF);      // Aba ativa 'Foco'
}

class AppTypography {
  static TextStyle eyebrow({Color color = AppColors.textEyebrow}) {
    return GoogleFonts.dmMono(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.4,
      color: color,
    );
  }

  static TextStyle serifTitle({double size = 24, Color color = AppColors.textDark}) {
    return GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle timerDigits() {
    return GoogleFonts.dmMono(
      fontSize: 44,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.0,
      color: AppColors.textLight,
    );
  }

  static TextStyle body({double size = 13, FontWeight weight = FontWeight.w500, Color color = AppColors.textDark}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}