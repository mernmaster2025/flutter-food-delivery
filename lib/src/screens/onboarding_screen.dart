import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  final _selected = <String>{'Spicy', 'Bowls'};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Skip'),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (value) => setState(() => _page = value),
              children: [
                _OnboardingPage(
                  title: 'Crave-worthy discovery',
                  body:
                      'Aurora-powered recommendations surface restaurants, rewards, and dishes that fit your rhythm.',
                  colors: const [0xFFFF7A1A, 0xFFFF4F6D],
                  icon: Icons.explore_rounded,
                ),
                _OnboardingPage(
                  title: 'Live delivery theatre',
                  body:
                      'Follow prep, pickup, and delivery with a polished tracking experience that feels alive.',
                  colors: const [0xFF8D5CFF, 0xFF35C2FF],
                  icon: Icons.delivery_dining_rounded,
                ),
                _PreferencesPage(
                  selected: _selected,
                  onToggle: (label) {
                    setState(() {
                      _selected.contains(label)
                          ? _selected.remove(label)
                          : _selected.add(label);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: _page == index ? 28 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  gradient: _page == index ? FoodFlowGradients.sunset : null,
                  color: _page == index
                      ? null
                      : Colors.white.withValues(alpha: .24),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: _page == 2 ? 'Personalize FoodFlow' : 'Continue',
            icon: _page == 2
                ? Icons.auto_awesome_rounded
                : Icons.arrow_forward_rounded,
            onPressed: () {
              if (_page == 2) {
                context.go('/auth');
              } else {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.colors,
    required this.icon,
  });

  final String title;
  final String body;
  final List<int> colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FoodOrb(colors: colors, icon: icon, size: 190),
                const SizedBox(height: 42),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PreferencesPage extends StatelessWidget {
  const _PreferencesPage({required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    const chips = [
      'Spicy',
      'Sushi',
      'Bowls',
      'Vegan',
      'Late night',
      'Pizza',
      'Dessert',
      'High protein',
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FoodOrb(
                  colors: [0xFF00D18F, 0xFFB8FF4D],
                  icon: Icons.tune_rounded,
                  size: 148,
                ),
                const SizedBox(height: 34),
                Text(
                  'Tune your taste profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pick a few cravings and FoodFlow will shape recommendations around you.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final chip in chips)
                      CategoryChip(
                        label: chip,
                        selected: selected.contains(chip),
                        onTap: () => onToggle(chip),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                GlassCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: FoodFlowColors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Location access enabled for nearby restaurants and precise ETA previews.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
