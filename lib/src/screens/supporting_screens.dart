import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../domain/foodflow_models.dart';
import '../state/foodflow_state.dart';
import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

final _currency = NumberFormat.simpleCurrency();

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return ScreenShell(
      bottomNavigationIndex: 2,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
      child: ListView(
        children: [
          Text(
            'Orders history',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 18),
          orders.when(
            data: (items) => Column(
              children: [
                for (final order in items) ...[
                  _OrderHistoryCard(order: order),
                  const SizedBox(height: 14),
                ],
              ],
            ),
            loading: () => const SkeletonLoader(),
            error: (_, _) => const Text('Receipts are offline.'),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends ConsumerWidget {
  const _OrderHistoryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FoodOrb(
                colors: [0xFFFF7A1A, 0xFFFF4F6D],
                size: 64,
                icon: Icons.receipt_long_rounded,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text('${order.id} • ${order.createdLabel}'),
                  ],
                ),
              ),
              Text(
                _currency.format(order.total),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.items
                .map((line) => '${line.quantity}x ${line.item.name}')
                .join(', '),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Reorder',
                  icon: Icons.repeat_rounded,
                  onPressed: () {
                    for (final line in order.items) {
                      ref.read(cartProvider.notifier).add(line.item);
                    }
                    context.push('/cart');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GradientButton(
                  label: 'Review',
                  gradient: FoodFlowGradients.electric,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantsProvider);
    return ScreenShell(
      child: ListView(
        children: [
          _SimpleHeader(title: 'Favorites', route: '/home'),
          const SizedBox(height: 18),
          restaurants.when(
            data: (items) {
              final favoriteRestaurants = items
                  .where((restaurant) => restaurant.isFavorite)
                  .toList();
              final favoriteDishes = items
                  .expand((restaurant) => restaurant.menu)
                  .where((item) => item.isFavorite)
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Favorite restaurants'),
                  for (final restaurant in favoriteRestaurants) ...[
                    RestaurantCard(restaurant: restaurant, compact: true),
                    const SizedBox(height: 14),
                  ],
                  const SectionHeader(title: 'Saved meals'),
                  for (final dish in favoriteDishes) ...[
                    FoodCard(
                      item: dish,
                      onAdd: () => ref.read(cartProvider.notifier).add(dish),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const SectionHeader(title: 'Collections'),
                  const GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date Night Delivery',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '12 restaurants • premium picks • saved for Friday',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const SkeletonLoader(),
            error: (_, _) => const Text('Favorites are offline.'),
          ),
        ],
      ),
    );
  }
}

class PromotionsScreen extends ConsumerWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promotions = ref.watch(promotionsProvider);
    return ScreenShell(
      child: ListView(
        children: [
          _SimpleHeader(title: 'Promotions', route: '/home'),
          const SizedBox(height: 18),
          promotions.when(
            data: (items) => Column(
              children: [
                for (final promo in items) ...[
                  PromotionBanner(
                    promotion: promo,
                    onApply: () =>
                        ref.read(cartProvider.notifier).applyPromo(promo),
                  ),
                  const SizedBox(height: 14),
                ],
                const GlassCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.group_add_rounded,
                        color: FoodFlowColors.emerald,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Refer a friend and both of you get 2,000 points plus priority delivery.',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            loading: () => const SkeletonLoader(),
            error: (_, _) => const Text('Promotions are offline.'),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reward = ref.watch(rewardProvider);
    return ScreenShell(
      bottomNavigationIndex: 3,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
      child: ListView(
        children: [
          Row(
            children: [
              const FoodOrb(
                colors: [0xFF8D5CFF, 0xFF35C2FF],
                icon: Icons.person_rounded,
                size: 86,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Rivera',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text('Platinum member • 142 orders'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.push('/settings'),
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          reward.when(
            data: (value) => RewardCard(reward: value),
            loading: () => const SkeletonLoader(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          _ProfileTile(
            icon: Icons.location_on_rounded,
            title: 'Saved addresses',
            body: 'Home, work, gym',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.payments_rounded,
            title: 'Payment methods',
            body: 'Apple Pay, Visa, PayPal, cash',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.favorite_rounded,
            title: 'Favorites and collections',
            body: 'Restaurants, dishes, meals',
            onTap: () => context.push('/favorites'),
          ),
          _ProfileTile(
            icon: Icons.local_offer_rounded,
            title: 'Promotions and referrals',
            body: 'Rewards, VIP offers, invite friends',
            onTap: () => context.push('/promotions'),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: ListView(
        children: [
          _SimpleHeader(title: 'Settings', route: '/profile'),
          const SizedBox(height: 18),
          const _SettingsToggle(
            title: 'Order updates',
            body: 'Push notifications for prep, pickup, and ETA',
            value: true,
          ),
          const _SettingsToggle(
            title: 'Personalized recommendations',
            body: 'Let AI tune the home feed',
            value: true,
          ),
          const _SettingsToggle(
            title: 'Face ID checkout',
            body: 'Confirm high-value orders with biometrics',
            value: false,
          ),
          const _SettingsToggle(
            title: 'Dark luxury theme',
            body: 'Aurora colors and glass surfaces',
            value: true,
          ),
          _ProfileTile(
            icon: Icons.language_rounded,
            title: 'Language',
            body: 'English',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy controls',
            body: 'Location, analytics, personalization',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class AiAssistantScreen extends ConsumerWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(aiSuggestionsProvider);
    return ScreenShell(
      child: ListView(
        children: [
          _SimpleHeader(title: 'AI Food Assistant', route: '/home'),
          const SizedBox(height: 18),
          PremiumSearchBar(
            hint: 'Tell FoodFlow what you crave',
            initialValue: ref.watch(aiPreferenceProvider),
            onChanged: (value) =>
                ref.read(aiPreferenceProvider.notifier).set(value),
          ),
          const SizedBox(height: 18),
          GlassCard(
            gradient: FoodFlowGradients.electric,
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Smart search blends cuisine, dietary goals, weather, order history, and nearby kitchen velocity.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          suggestions.when(
            data: (items) => Column(
              children: [
                for (final suggestion in items) ...[
                  GlassCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.bubble_chart_rounded,
                          color: FoodFlowColors.amber,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
            loading: () => const SkeletonLoader(),
            error: (_, _) => const Text('FoodFlow AI is thinking.'),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return ScreenShell(
      child: ListView(
        children: [
          _SimpleHeader(title: 'Notifications', route: '/home'),
          const SizedBox(height: 18),
          notifications.when(
            data: (items) => Column(
              children: [
                for (final item in items) ...[
                  GlassCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.notifications_active_rounded,
                          color: FoodFlowColors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(item.body),
                              const SizedBox(height: 6),
                              Text(
                                item.time,
                                style: const TextStyle(
                                  color: FoodFlowColors.subtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
            loading: () => const SkeletonLoader(),
            error: (_, _) => const Text('Notifications unavailable.'),
          ),
        ],
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({required this.title, required this.route});

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GlassCard(
          onTap: () => context.go(route),
          radius: 18,
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineLarge),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: FoodFlowColors.orange),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(body),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatefulWidget {
  const _SettingsToggle({
    required this.title,
    required this.body,
    required this.value,
  });

  final String title;
  final String body;
  final bool value;

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> {
  late bool _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(widget.body),
                ],
              ),
            ),
            Switch(
              value: _value,
              activeThumbColor: FoodFlowColors.lime,
              onChanged: (value) => setState(() => _value = value),
            ),
          ],
        ),
      ),
    );
  }
}
