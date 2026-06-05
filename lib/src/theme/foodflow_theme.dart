import 'package:flutter/material.dart';

class FoodFlowColors {
  static const ink = Color(0xFF100B1F);
  static const night = Color(0xFF080711);
  static const plum = Color(0xFF24143D);
  static const orange = Color(0xFFFF7A1A);
  static const coral = Color(0xFFFF4F6D);
  static const amber = Color(0xFFFFC857);
  static const emerald = Color(0xFF00D18F);
  static const lime = Color(0xFFB8FF4D);
  static const pink = Color(0xFFFF4FD8);
  static const purple = Color(0xFF8D5CFF);
  static const blue = Color(0xFF35C2FF);
  static const glass = Color(0x24FFFFFF);
  static const glassStrong = Color(0x3DFFFFFF);
  static const text = Color(0xFFFDF7FF);
  static const muted = Color(0xCCF4EAFE);
  static const subtle = Color(0x99F4EAFE);
}

class FoodFlowSpacing {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 44.0;
}

class FoodFlowRadii {
  static const sm = 14.0;
  static const md = 22.0;
  static const lg = 30.0;
  static const xl = 38.0;
}

class FoodFlowGradients {
  static const sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FoodFlowColors.orange, FoodFlowColors.coral, FoodFlowColors.pink],
  );

  static const fresh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FoodFlowColors.emerald, FoodFlowColors.lime],
  );

  static const electric = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FoodFlowColors.purple, FoodFlowColors.blue],
  );

  static const luxury = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [FoodFlowColors.night, FoodFlowColors.ink, FoodFlowColors.plum],
  );
}

class FoodFlowTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FoodFlowColors.night,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FoodFlowColors.orange,
        brightness: Brightness.dark,
        primary: FoodFlowColors.orange,
        secondary: FoodFlowColors.emerald,
        tertiary: FoodFlowColors.purple,
        surface: FoodFlowColors.ink,
      ),
      textTheme: _textTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: FoodFlowColors.text,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: FoodFlowColors.orange,
        unselectedItemColor: FoodFlowColors.subtle,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: FoodFlowColors.glass,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FoodFlowRadii.lg)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FoodFlowColors.glass,
        hintStyle: const TextStyle(color: FoodFlowColors.subtle),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FoodFlowRadii.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    const family = 'SF Pro Display';
    return base
        .copyWith(
          displayLarge: base.displayLarge?.copyWith(
            fontSize: 54,
            height: .96,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.2,
            color: FoodFlowColors.text,
          ),
          headlineLarge: base.headlineLarge?.copyWith(
            fontSize: 34,
            height: 1.02,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: FoodFlowColors.text,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -.6,
            color: FoodFlowColors.text,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: FoodFlowColors.text,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: FoodFlowColors.text,
          ),
          bodyLarge: base.bodyLarge?.copyWith(
            color: FoodFlowColors.muted,
            height: 1.35,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            color: FoodFlowColors.subtle,
            height: 1.35,
          ),
          labelLarge: base.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: .2,
            color: FoodFlowColors.text,
          ),
        )
        .apply(fontFamily: family);
  }
}
