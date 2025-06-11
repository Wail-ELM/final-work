import 'package:flutter/material.dart';

/// 🌿 Social Balans Design System - Digital Wellness Edition
/// Système de design axé sur le bien-être et l'équilibre numérique
class AppDesignSystem {
  // 🌿 COULEURS BIEN-ÊTRE - Palette principale
  // Inspirée de la nature, du calme et de l'équilibre

  // Verts apaisants - Couleur primaire (croissance, équilibre, nature)
  static const Color primaryGreen = Color(0xFF16A085); // Vert émeraude doux
  static const Color primaryGreenLight = Color(0xFF1ABC9C); // Vert turquoise
  static const Color primaryGreenDark = Color(0xFF0F7864); // Vert foncé

  // Bleus calmes - Couleur secondaire (tranquillité, sérénité)
  static const Color secondaryBlue = Color(0xFF3498DB); // Bleu ciel
  static const Color secondaryBlueLight = Color(0xFF5DADE2); // Bleu clair
  static const Color secondaryBlueDark = Color(0xFF2980B9); // Bleu profond

  // Couleurs d'état - harmonisées avec le thème bien-être
  static const Color success = Color(0xFF27AE60); // Vert succès naturel
  static const Color warning = Color(0xFFE67E22); // Orange terre cuite
  static const Color error = Color(0xFFE74C3C); // Rouge corail doux
  static const Color info = Color(0xFF3498DB); // Bleu information

  // Tons terreux et chaleureux
  static const Color warmBeige = Color(0xFFF5F5DC); // Beige doux
  static const Color earthBrown = Color(0xFF8D6E63); // Brun terreux
  static const Color softCream = Color(0xFFFAF0E6); // Crème douce
  static const Color sageGreen = Color(0xFF9CAF88); // Vert sauge

  // Palette neutre organique
  static const Color neutral50 = Color(0xFFFCFCFC); // Blanc cassé
  static const Color neutral100 = Color(0xFFF8F9FA); // Gris très clair
  static const Color neutral200 = Color(0xFFE9ECEF); // Gris clair
  static const Color neutral300 = Color(0xFFCED4DA); // Gris moyen clair
  static const Color neutral400 = Color(0xFF95A5A6); // Gris moyen
  static const Color neutral500 = Color(0xFF6C757D); // Gris
  static const Color neutral600 = Color(0xFF495057); // Gris foncé
  static const Color neutral700 = Color(0xFF343A40); // Gris très foncé
  static const Color neutral800 = Color(0xFF2C3E50); // Bleu gris foncé
  static const Color neutral900 = Color(0xFF1A252F); // Presque noir

  // 🌈 GRADIENTS APAISANTS
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryGreenLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryBlue, secondaryBlueLight],
    stops: [0.0, 1.0],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF2ECC71)],
    stops: [0.0, 1.0],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warmBeige, softCream],
    stops: [0.0, 1.0],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA8E6CF), Color(0xFFDCEDC1)], // Vert menthe à crème
    stops: [0.0, 1.0],
  );

  // 📏 ESPACEMENTS STANDARDISÉS
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // 🔤 TYPOGRAPHIE MODERNE
  static const String fontFamily = 'Inter';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.25,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: neutral500,
  );

  //  BORDURES ET RAYONS
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius borderRadiusSmall =
      BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMedium =
      BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLarge =
      BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusXLarge =
      BorderRadius.all(Radius.circular(radiusXLarge));

  // 🎭 OMBRES MODERNES - VERSION AMÉLIORÉE
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x12000000), // Plus prononcée
      blurRadius: 8,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x04000000), // Ombre secondaire pour plus de profondeur
      blurRadius: 3,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x18000000), // Plus prononcée
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x08000000), // Ombre secondaire
      blurRadius: 6,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x20000000), // Plus prononcée
      blurRadius: 32,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x10000000), // Ombre secondaire
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // 🌟 NOUVELLES OMBRES ÉLÉGANTES POUR CARTES SPÉCIALES
  static const List<BoxShadow> shadowElegant = [
    BoxShadow(
      color: Color(0x15000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: -1,
    ),
  ];

  // 🎨 OMBRES COLORÉES POUR ÉLÉMENTS WELLNESS
  static List<BoxShadow> get shadowWellness => [
        BoxShadow(
          color: primaryGreen.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: primaryGreen.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get shadowCalm => [
        BoxShadow(
          color: secondaryBlue.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: secondaryBlue.withOpacity(0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
      ];

  //  THÈMES
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.light(
          primary: primaryGreen,
          primaryContainer: primaryGreenLight.withOpacity(0.1),
          onPrimary: Colors.white,
          onPrimaryContainer: primaryGreenDark,
          secondary: secondaryBlue,
          secondaryContainer: secondaryBlueLight.withOpacity(0.1),
          onSecondary: Colors.white,
          onSecondaryContainer: secondaryBlueDark,
          surface: neutral50,
          surfaceContainerHighest: neutral100,
          onSurface: neutral800,
          onSurfaceVariant: neutral600,
          background: Colors.white,
          onBackground: neutral800,
          error: error,
          onError: Colors.white,
          outline: neutral300,
          outlineVariant: neutral200,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: Colors.white,
          shadowColor: primaryGreen.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusLarge,
            side: BorderSide(color: neutral200, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white.withOpacity(0.95),
          foregroundColor: neutral800,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: neutral700),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: space24, vertical: space16),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
            textStyle: body1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryGreen,
          unselectedItemColor: neutral400,
          elevation: 8,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.dark(
          primary: primaryGreenLight,
          primaryContainer: primaryGreen.withOpacity(0.2),
          onPrimary: neutral900,
          onPrimaryContainer: primaryGreenLight,
          secondary: secondaryBlueLight,
          secondaryContainer: secondaryBlue.withOpacity(0.2),
          onSecondary: neutral900,
          onSecondaryContainer: secondaryBlueLight,
          surface: neutral800,
          surfaceContainerHighest: neutral700,
          onSurface: neutral100,
          onSurfaceVariant: neutral300,
          background: neutral900,
          onBackground: neutral100,
          error: error,
          onError: Colors.white,
          outline: neutral600,
          outlineVariant: neutral700,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: neutral800,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadiusLarge,
            side: BorderSide(color: neutral700, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: neutral900.withOpacity(0.95),
          foregroundColor: neutral100,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: neutral200),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryGreenLight,
            foregroundColor: neutral900,
            padding: const EdgeInsets.symmetric(
                horizontal: space24, vertical: space16),
            shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
            textStyle: body1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryGreenLight,
          foregroundColor: neutral900,
          elevation: 4,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: neutral800,
          selectedItemColor: primaryGreenLight,
          unselectedItemColor: neutral400,
          elevation: 8,
        ),
      );
}

/// 🌿 WIDGETS CUSTOM - Digital Wellness Edition
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool hasGradient;
  final String gradientType;
  final bool usePremiumShadow; // Nouvelle option pour ombres élégantes
  final bool useWellnessShadow; // Nouvelle option pour ombres wellness

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.hasGradient = false,
    this.gradientType = 'primary',
    this.usePremiumShadow = false,
    this.useWellnessShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    Gradient? gradient;

    if (hasGradient) {
      switch (gradientType) {
        case 'secondary':
          gradient = AppDesignSystem.secondaryGradient;
          break;
        case 'warm':
          gradient = AppDesignSystem.warmGradient;
          break;
        case 'calm':
          gradient = AppDesignSystem.calmGradient;
          break;
        case 'success':
          gradient = AppDesignSystem.successGradient;
          break;
        default:
          gradient = AppDesignSystem.primaryGradient;
      }
    }

    // Sélection des ombres appropriées
    List<BoxShadow> cardShadow;
    if (useWellnessShadow) {
      cardShadow = AppDesignSystem.shadowWellness;
    } else if (usePremiumShadow) {
      cardShadow = AppDesignSystem.shadowElegant;
    } else {
      cardShadow = AppDesignSystem.shadowMedium;
    }

    final widget = Container(
      padding: padding ?? const EdgeInsets.all(AppDesignSystem.space20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: hasGradient ? null : (color ?? Theme.of(context).cardColor),
        borderRadius: AppDesignSystem.borderRadiusLarge,
        boxShadow: cardShadow,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppDesignSystem.neutral700.withOpacity(0.3)
              : AppDesignSystem.neutral200.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDesignSystem.borderRadiusLarge,
          splashColor: AppDesignSystem.primaryGreen.withOpacity(0.1),
          highlightColor: AppDesignSystem.primaryGreen.withOpacity(0.05),
          child: widget,
        ),
      );
    }

    return widget;
  }
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonStyle style; // 'primary', 'secondary', 'success', 'warm'
  final IconData? icon;
  final bool expandWidth;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.style = ButtonStyle.primary,
    this.icon,
    this.expandWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Gradient? gradient;

    switch (style) {
      case ButtonStyle.secondary:
        gradient = AppDesignSystem.secondaryGradient;
        textColor = Colors.white;
        backgroundColor = AppDesignSystem.secondaryBlue;
        break;
      case ButtonStyle.success:
        gradient = AppDesignSystem.successGradient;
        textColor = Colors.white;
        backgroundColor = AppDesignSystem.success;
        break;
      case ButtonStyle.warm:
        gradient = AppDesignSystem.warmGradient;
        textColor = AppDesignSystem.neutral700;
        backgroundColor = AppDesignSystem.warmBeige;
        break;
      case ButtonStyle.outline:
        gradient = null;
        textColor = AppDesignSystem.primaryGreen;
        backgroundColor = Colors.transparent;
        break;
      default: // primary
        gradient = AppDesignSystem.primaryGradient;
        textColor = Colors.white;
        backgroundColor = AppDesignSystem.primaryGreen;
    }

    final button = Container(
      height: 56,
      constraints: expandWidth
          ? const BoxConstraints(minWidth: double.infinity)
          : const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: AppDesignSystem.borderRadiusMedium,
        boxShadow: style != ButtonStyle.outline
            ? (style == ButtonStyle.primary
                ? AppDesignSystem.shadowWellness
                : AppDesignSystem.shadowMedium)
            : null,
        border: style == ButtonStyle.outline
            ? Border.all(color: AppDesignSystem.primaryGreen, width: 2)
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppDesignSystem.borderRadiusMedium,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor),
                    const SizedBox(width: AppDesignSystem.space8),
                  ],
                  Text(
                    text,
                    style: AppDesignSystem.body1.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );

    return expandWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

// Énumération pour les styles de boutons
enum ButtonStyle {
  primary,
  secondary,
  success,
  warm,
  outline,
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final bool useWellnessColors;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.useWellnessColors = true,
  });

  @override
  Widget build(BuildContext context) {
    // Utiliser les couleurs bien-être par défaut si aucune couleur n'est spécifiée
    final cardColor = color ??
        (useWellnessColors
            ? AppDesignSystem.primaryGreen
            : Theme.of(context).primaryColor);

    return ModernCard(
      padding: const EdgeInsets.all(AppDesignSystem.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: AppDesignSystem.borderRadiusSmall,
                ),
                child: Icon(icon, color: cardColor, size: 20),
              ),
              const Spacer(),
              if (subtitle != null)
                Flexible(
                  child: Text(
                    subtitle!,
                    style: AppDesignSystem.caption.copyWith(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDesignSystem.space12),
          Flexible(
            child: Text(
              value,
              style: AppDesignSystem.heading3.copyWith(
                color: cardColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppDesignSystem.space4),
          Flexible(
            child: Text(
              title,
              style: AppDesignSystem.body2.copyWith(
                color: AppDesignSystem.neutral500,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌟 CARTE INSIGHT WELLNESS - DESIGN PREMIUM
class WellnessInsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? value;
  final Color? accentColor;
  final VoidCallback? onTap;

  const WellnessInsightCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.value,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppDesignSystem.primaryGreen;

    return ModernCard(
      useWellnessShadow: true,
      onTap: onTap,
      padding: const EdgeInsets.all(AppDesignSystem.space24),
      child: Row(
        children: [
          // Icône avec arrière-plan gradienté
          Container(
            padding: const EdgeInsets.all(AppDesignSystem.space16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: AppDesignSystem.space20),

          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (value != null) ...[
                  Text(
                    value!,
                    style: AppDesignSystem.heading2.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDesignSystem.space4),
                ],
                Text(
                  title,
                  style: AppDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppDesignSystem.neutral800,
                  ),
                ),
                const SizedBox(height: AppDesignSystem.space8),
                Text(
                  description,
                  style: AppDesignSystem.body2.copyWith(
                    color: AppDesignSystem.neutral600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Flèche indicatrice si cliquable
          if (onTap != null)
            Container(
              padding: const EdgeInsets.all(AppDesignSystem.space8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusFull),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
