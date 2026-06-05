import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../domain/foodflow_models.dart';
import '../state/foodflow_state.dart';
import '../theme/foodflow_theme.dart';
import '../widgets/premium_components.dart';

final _currency = NumberFormat.simpleCurrency();

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(filteredRestaurantsProvider);
    final selectedView = ref.watch(discoveryViewProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    const filters = [
      'All',
      'Trending',
      'Healthy',
      'Spicy',
      'Open late',
      'Vegetarian',
      'Top rated',
      'Fast',
    ];

    return ScreenShell(
      bottomNavigationIndex: 1,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Discover kitchens',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              GlassCard(
                onTap: () => context.push('/notifications'),
                radius: 18,
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.notifications_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PremiumSearchBar(
            hint: 'Search restaurants, dishes, cravings',
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).set(value),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = filters[index];
                return CategoryChip(
                  label: filter,
                  selected: selectedCategory == filter,
                  onTap: () =>
                      ref.read(selectedCategoryProvider.notifier).set(filter),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _DiscoveryControls(selectedView: selectedView),
          const SizedBox(height: 18),
          restaurants.when(
            data: (items) {
              if (selectedView == DiscoveryView.map) {
                return _MapDiscovery(restaurants: items);
              }
              if (selectedView == DiscoveryView.list) {
                return Column(
                  children: [
                    for (final restaurant in items) ...[
                      RestaurantCard(restaurant: restaurant, compact: true),
                      const SizedBox(height: 14),
                    ],
                  ],
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 16,
                  childAspectRatio: .92,
                ),
                itemBuilder: (context, index) =>
                    RestaurantCard(restaurant: items[index]),
              );
            },
            loading: () => const SkeletonLoader(),
            error: (_, _) =>
                const Text('Discovery filters are offline right now.'),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryControls extends ConsumerWidget {
  const _DiscoveryControls({required this.selectedView});

  final DiscoveryView selectedView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      (DiscoveryView.grid, Icons.grid_view_rounded, 'Grid'),
      (DiscoveryView.list, Icons.view_agenda_rounded, 'List'),
      (DiscoveryView.map, Icons.map_rounded, 'Map'),
    ];
    return GlassCard(
      padding: const EdgeInsets.all(6),
      radius: 24,
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    ref.read(discoveryViewProvider.notifier).set(option.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: selectedView == option.$1
                        ? FoodFlowGradients.electric
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(option.$2, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        option.$3,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapDiscovery extends StatelessWidget {
  const _MapDiscovery({required this.restaurants});

  final List<Restaurant> restaurants;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 520,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _DiscoveryMapPainter()),
            ),
            for (var i = 0; i < restaurants.length; i++)
              Positioned(
                left: 34.0 + (i % 2) * 170,
                top: 70.0 + i * 82,
                child: GestureDetector(
                  onTap: () => context.push('/restaurant/${restaurants[i].id}'),
                  child: Column(
                    children: [
                      FoodOrb(
                        colors: restaurants[i].accentColors,
                        size: 58,
                        icon: Icons.restaurant_rounded,
                      ),
                      const SizedBox(height: 6),
                      Text(restaurants[i].name.split(' ').take(2).join(' ')),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .07)
      ..strokeWidth = 2;
    for (var i = 0; i < 8; i++) {
      final y = 30.0 + i * 62;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 28), paint);
    }
    for (var i = 0; i < 6; i++) {
      final x = 20.0 + i * 68;
      canvas.drawLine(Offset(x, 0), Offset(x + 56, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RestaurantDetailsScreen extends ConsumerWidget {
  const RestaurantDetailsScreen({required this.restaurantId, super.key});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurant = ref.watch(restaurantByIdProvider(restaurantId));
    if (restaurant == null) {
      return const ScreenShell(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final reviews = [
      const Review(
        author: 'Nora',
        rating: 5,
        text:
            'The plating survived delivery and tasted like a restaurant night out.',
        reactions: 238,
      ),
      const Review(
        author: 'Miles',
        rating: 4.9,
        text: 'Fast, warm, and the flavor notes were exactly as described.',
        reactions: 91,
      ),
    ];
    return ScreenShell(
      padding: EdgeInsets.zero,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 310,
            pinned: true,
            backgroundColor: FoodFlowColors.ink,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.ios_share_rounded),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: restaurant.accentColors.map(Color.new).toList(),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 18,
                      bottom: 26,
                      child: FoodOrb(
                        colors: restaurant.accentColors,
                        size: 170,
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 36,
                      child: Text(
                        restaurant.name,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            sliver: SliverList.list(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    CategoryChip(
                      label: restaurant.cuisine,
                      selected: true,
                      onTap: () {},
                    ),
                    CategoryChip(
                      label: '${restaurant.deliveryMinutes} min',
                      selected: false,
                      onTap: () {},
                    ),
                    CategoryChip(
                      label: '${restaurant.distanceKm} km',
                      selected: false,
                      onTap: () {},
                    ),
                    CategoryChip(
                      label: '${restaurant.rating} rating',
                      selected: false,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  restaurant.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                PromotionBanner(
                  promotion: Promotion(
                    id: 'restaurant-promo',
                    title: restaurant.promo,
                    subtitle: 'Auto-applied for eligible FoodFlow members',
                    code: 'CHEF',
                    discount: .18,
                    accentColors: restaurant.accentColors,
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Popular Items'),
                for (final item in restaurant.menu.where(
                  (item) => item.isPopular,
                )) ...[
                  FoodCard(
                    item: item,
                    onAdd: () => ref.read(cartProvider.notifier).add(item),
                  ),
                  const SizedBox(height: 14),
                ],
                const SectionHeader(title: 'Full Menu'),
                for (final item in restaurant.menu) ...[
                  FoodCard(
                    item: item,
                    onAdd: () => ref.read(cartProvider.notifier).add(item),
                  ),
                  const SizedBox(height: 14),
                ],
                const SectionHeader(title: 'Reviews'),
                for (final review in reviews) ...[
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.author,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star_rounded,
                              color: FoodFlowColors.amber,
                              size: 18,
                            ),
                            Text(review.rating.toStringAsFixed(1)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(review.text),
                        const SizedBox(height: 8),
                        Text('${review.reactions} found this helpful'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const SectionHeader(title: 'Information'),
                const GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hours: 10:30 AM - 12:00 AM'),
                      SizedBox(height: 8),
                      Text('Delivery: Priority, scheduled, group order'),
                      SizedBox(height: 8),
                      Text(
                        'Accessibility: Contactless drop-off and dietary labels available',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FoodDetailsScreen extends ConsumerStatefulWidget {
  const FoodDetailsScreen({required this.itemId, super.key});

  final String itemId;

  @override
  ConsumerState<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends ConsumerState<FoodDetailsScreen> {
  final _addons = <MenuAddon>{};
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final item = ref.watch(menuItemByIdProvider(widget.itemId));
    if (item == null) {
      return const ScreenShell(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final addonTotal = _addons.fold<double>(
      0,
      (sum, addon) => sum + addon.price,
    );
    final total = (item.price + addonTotal) * _quantity;
    return ScreenShell(
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GlassCard(
              onTap: () => context.pop(),
              radius: 18,
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(height: 18),
          Hero(
            tag: 'food-${item.id}',
            child: FoodOrb(
              colors: item.accentColors,
              icon: Icons.lunch_dining_rounded,
              size: 220,
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: FoodFlowColors.coral,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.description, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CategoryChip(
                label: '${item.calories} cal',
                selected: true,
                onTap: () {},
              ),
              CategoryChip(
                label: '${item.prepMinutes} min',
                selected: false,
                onTap: () {},
              ),
              CategoryChip(
                label: '${item.rating} stars',
                selected: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Ingredients'),
          GlassCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final ingredient in item.ingredients)
                  CategoryChip(
                    label: ingredient,
                    selected: false,
                    onTap: () {},
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeader(title: 'Customizations'),
          for (final addon in item.addons) ...[
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CheckboxListTile(
                value: _addons.contains(addon),
                onChanged: (value) {
                  setState(() {
                    value == true ? _addons.add(addon) : _addons.remove(addon);
                  });
                },
                title: Text(addon.name),
                subtitle: Text('+${_currency.format(addon.price)}'),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          GlassCard(
            child: Row(
              children: [
                Text(
                  'Quantity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_rounded),
                ),
                AnimatedCounter(value: _quantity.toDouble()),
                IconButton(
                  onPressed: () => setState(() => _quantity++),
                  icon: const Icon(Icons.add_circle_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Add ${_currency.format(total)}',
                  icon: Icons.add_shopping_cart_rounded,
                  onPressed: () {
                    for (var i = 0; i < _quantity; i++) {
                      ref
                          .read(cartProvider.notifier)
                          .add(item, addons: _addons.toList());
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} added to cart')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'Buy now',
                  gradient: FoodFlowGradients.fresh,
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .add(item, addons: _addons.toList());
                    context.push('/checkout');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
