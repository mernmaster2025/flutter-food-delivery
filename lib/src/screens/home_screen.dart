import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/foodflow_state.dart';
import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantsProvider);
    final promotions = ref.watch(promotionsProvider);
    final reward = ref.watch(rewardProvider);
    final ai = ref.watch(aiSuggestionsProvider);
    final cart = ref.watch(cartProvider);

    return ScreenShell(
      bottomNavigationIndex: 0,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
      child: RefreshIndicator(
        color: FoodFlowColors.orange,
        backgroundColor: FoodFlowColors.ink,
        onRefresh: () async {
          ref.invalidate(restaurantsProvider);
          ref.invalidate(promotionsProvider);
          await ref.read(restaurantsProvider.future);
        },
        child: ListView(
          children: [
            _HomeTopBar(cartCount: cart.count),
            const SizedBox(height: 22),
            _HeroDashboard(onOrderNow: () => context.push('/discover')),
            const SizedBox(height: 22),
            promotions.when(
              data: (items) => PromotionBanner(
                promotion: items.first,
                onApply: () =>
                    ref.read(cartProvider.notifier).applyPromo(items.first),
              ),
              loading: () => const SkeletonLoader(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            const _CategoryRail(),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'AI recommendations',
              actionLabel: 'Ask',
              onAction: () => context.push('/assistant'),
            ),
            ai.when(
              data: (suggestions) => _AiCard(suggestions: suggestions),
              loading: () => const SkeletonLoader(),
              error: (_, _) => const Text('AI recommendations are warming up.'),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Popular near you',
              actionLabel: 'Map',
              onAction: () => context.push('/discover'),
            ),
            restaurants.when(
              data: (items) => SizedBox(
                height: 318,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) => SizedBox(
                    width: 286,
                    child: _Reveal(
                      delay: index * 80,
                      child: RestaurantCard(restaurant: items[index]),
                    ),
                  ),
                ),
              ),
              loading: () => const SkeletonLoader(),
              error: (_, _) => const Text('Unable to load restaurants.'),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Craveable dishes',
              actionLabel: 'Search',
              onAction: () => context.push('/discover'),
            ),
            restaurants.when(
              data: (items) {
                final dishes = items
                    .expand((restaurant) => restaurant.menu)
                    .where((item) => item.isPopular)
                    .toList();
                return Column(
                  children: [
                    for (var i = 0; i < dishes.length; i++) ...[
                      _Reveal(
                        delay: i * 70,
                        child: FoodCard(
                          item: dishes[i],
                          onAdd: () =>
                              ref.read(cartProvider.notifier).add(dishes[i]),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              },
              loading: () => const SkeletonLoader(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 10),
            reward.when(
              data: (value) => RewardCard(reward: value),
              loading: () => const SkeletonLoader(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good evening, Alex',
                style: TextStyle(color: FoodFlowColors.subtle),
              ),
              Text(
                'What should flow to you?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GlassCard(
              onTap: () => context.push('/cart'),
              radius: 20,
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.shopping_bag_rounded),
            ),
            if (cartCount > 0)
              Positioned(
                right: -4,
                top: -5,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: FoodFlowGradients.sunset,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HeroDashboard extends StatelessWidget {
  const _HeroDashboard({required this.onOrderNow});

  final VoidCallback onOrderNow;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF7A1A), Color(0xFFFF4F6D), Color(0xFF8D5CFF)],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -18,
            child: Transform.rotate(
              angle: -.22,
              child: const FoodOrb(
                colors: [0xFFFFC857, 0xFFFF4F6D],
                icon: Icons.ramen_dining_rounded,
                size: 134,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 220),
              Text(
                'Tonight is curated for you',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              const Text(
                'Flash deals, chef picks, and rewards x2 are live within 2.5 km.',
                style: TextStyle(color: Colors.white, height: 1.35),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Order now',
                icon: Icons.bolt_rounded,
                expand: false,
                gradient: FoodFlowGradients.fresh,
                onPressed: onOrderNow,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends ConsumerWidget {
  const _CategoryRail();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    const categories = [
      'All',
      'Trending',
      'Healthy',
      'Spicy',
      'Open late',
      'Vegetarian',
      'Rewards',
    ];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final label = categories[index];
          return CategoryChip(
            label: label,
            selected: selected == label,
            onTap: () => ref.read(selectedCategoryProvider.notifier).set(label),
          );
        },
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({required this.suggestions});

  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () => context.push('/assistant'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: FoodFlowColors.amber,
              ),
              const SizedBox(width: 10),
              Text(
                'FoodFlow AI',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(suggestions.first, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _Reveal extends StatefulWidget {
  const _Reveal({required this.child, required this.delay});

  final Widget child;
  final int delay;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, .08),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
