import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
    Future<void>.delayed(const Duration(milliseconds: 1900), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: .86, end: 1).animate(
              CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FoodOrb(
                  colors: [0xFFFF7A1A, 0xFFFF4F6D, 0xFF8D5CFF],
                  icon: Icons.bolt_rounded,
                  size: 132,
                ),
                const SizedBox(height: 26),
                Text(
                  'FoodFlow',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Premium delivery in motion',
                  style: TextStyle(
                    color: FoodFlowColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
