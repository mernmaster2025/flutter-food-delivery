import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_food_repository.dart';
import '../domain/foodflow_models.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return MockFoodRepository();
});

final restaurantsProvider = FutureProvider<List<Restaurant>>((ref) {
  return ref.watch(foodRepositoryProvider).fetchRestaurants();
});

final promotionsProvider = FutureProvider<List<Promotion>>((ref) {
  return ref.watch(foodRepositoryProvider).fetchPromotions();
});

final ordersProvider = FutureProvider<List<Order>>((ref) {
  return ref.watch(foodRepositoryProvider).fetchOrders();
});

final rewardProvider = FutureProvider<Reward>((ref) {
  return ref.watch(foodRepositoryProvider).fetchReward();
});

final notificationsProvider = FutureProvider<List<FoodNotification>>((ref) {
  return ref.watch(foodRepositoryProvider).fetchNotifications();
});

final liveTrackingProvider = StreamProvider<OrderTracking>((ref) {
  return ref.watch(foodRepositoryProvider).watchLiveOrder();
});

final aiPreferenceProvider = NotifierProvider<AiPreferenceController, String>(
  AiPreferenceController.new,
);

final aiSuggestionsProvider = FutureProvider<List<String>>((ref) {
  final preference = ref.watch(aiPreferenceProvider);
  return ref.watch(foodRepositoryProvider).fetchAiSuggestions(preference);
});

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryController, String>(
      SelectedCategoryController.new,
    );
final searchQueryProvider = NotifierProvider<SearchQueryController, String>(
  SearchQueryController.new,
);
final discoveryViewProvider =
    NotifierProvider<DiscoveryViewController, DiscoveryView>(
      DiscoveryViewController.new,
    );

final filteredRestaurantsProvider = Provider<AsyncValue<List<Restaurant>>>((
  ref,
) {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final restaurants = ref.watch(restaurantsProvider);
  return restaurants.whenData((items) {
    return items.where((restaurant) {
      final categoryMatch =
          category == 'All' ||
          restaurant.cuisine.toLowerCase().contains(category.toLowerCase()) ||
          restaurant.tags.any(
            (tag) => tag.toLowerCase().contains(category.toLowerCase()),
          );
      final queryMatch =
          query.isEmpty ||
          restaurant.name.toLowerCase().contains(query) ||
          restaurant.cuisine.toLowerCase().contains(query) ||
          restaurant.menu.any(
            (item) => item.name.toLowerCase().contains(query),
          );
      return categoryMatch && queryMatch;
    }).toList();
  });
});

final restaurantByIdProvider = Provider.family<Restaurant?, String>((ref, id) {
  final restaurants =
      ref.watch(restaurantsProvider).asData?.value ?? const <Restaurant>[];
  return restaurants.where((restaurant) => restaurant.id == id).firstOrNull;
});

final menuItemByIdProvider = Provider.family<MenuItem?, String>((ref, id) {
  final restaurants =
      ref.watch(restaurantsProvider).asData?.value ?? const <Restaurant>[];
  for (final restaurant in restaurants) {
    for (final item in restaurant.menu) {
      if (item.id == id) {
        return item;
      }
    }
  }
  return null;
});

final cartProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  void add(MenuItem item, {List<MenuAddon> addons = const []}) {
    final existingIndex = state.lines.indexWhere(
      (line) => line.item.id == item.id,
    );
    if (existingIndex == -1) {
      state = state.copyWith(
        lines: [
          ...state.lines,
          CartLine(item: item, selectedAddons: addons),
        ],
      );
      return;
    }

    final lines = [...state.lines];
    final existing = lines[existingIndex];
    lines[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
    state = state.copyWith(lines: lines);
  }

  void remove(String itemId) {
    state = state.copyWith(
      lines: state.lines.where((line) => line.item.id != itemId).toList(),
    );
  }

  void increment(String itemId) {
    state = state.copyWith(
      lines: [
        for (final line in state.lines)
          if (line.item.id == itemId)
            line.copyWith(quantity: line.quantity + 1)
          else
            line,
      ],
    );
  }

  void decrement(String itemId) {
    state = state.copyWith(
      lines: [
        for (final line in state.lines)
          if (line.item.id == itemId && line.quantity > 1)
            line.copyWith(quantity: line.quantity - 1)
          else if (line.item.id != itemId)
            line,
      ],
    );
  }

  void applyPromo(Promotion promotion) {
    state = state.copyWith(appliedPromo: promotion);
  }

  void setTip(double tip) {
    state = state.copyWith(tip: tip);
  }

  void clear() {
    state = const CartState();
  }
}

enum DiscoveryView { grid, list, map }

class AiPreferenceController extends Notifier<String> {
  @override
  String build() => 'spicy, bright, fast';

  void set(String value) => state = value;
}

class SelectedCategoryController extends Notifier<String> {
  @override
  String build() => 'All';

  void set(String value) => state = value;
}

class SearchQueryController extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

class DiscoveryViewController extends Notifier<DiscoveryView> {
  @override
  DiscoveryView build() => DiscoveryView.grid;

  void set(DiscoveryView value) => state = value;
}

extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
