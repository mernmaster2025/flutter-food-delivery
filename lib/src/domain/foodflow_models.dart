enum OrderStage { confirmed, preparing, pickedUp, nearby, delivered }

class MenuAddon {
  const MenuAddon({required this.name, required this.price});

  final String name;
  final double price;
}

class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.calories,
    required this.rating,
    required this.prepMinutes,
    required this.accentColors,
    required this.ingredients,
    required this.addons,
    required this.isPopular,
    required this.isFavorite,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String category;
  final double price;
  final int calories;
  final double rating;
  final int prepMinutes;
  final List<int> accentColors;
  final List<String> ingredients;
  final List<MenuAddon> addons;
  final bool isPopular;
  final bool isFavorite;
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.deliveryMinutes,
    required this.distanceKm,
    required this.priceTier,
    required this.promo,
    required this.tags,
    required this.accentColors,
    required this.menu,
    required this.isTrending,
    required this.isFavorite,
  });

  final String id;
  final String name;
  final String cuisine;
  final String description;
  final double rating;
  final int reviewCount;
  final int deliveryMinutes;
  final double distanceKm;
  final String priceTier;
  final String promo;
  final List<String> tags;
  final List<int> accentColors;
  final List<MenuItem> menu;
  final bool isTrending;
  final bool isFavorite;
}

class Promotion {
  const Promotion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.discount,
    required this.accentColors,
  });

  final String id;
  final String title;
  final String subtitle;
  final String code;
  final double discount;
  final List<int> accentColors;
}

class CartLine {
  const CartLine({
    required this.item,
    this.quantity = 1,
    this.selectedAddons = const [],
  });

  final MenuItem item;
  final int quantity;
  final List<MenuAddon> selectedAddons;

  double get lineTotal {
    final addonsTotal = selectedAddons.fold<double>(
      0,
      (sum, addon) => sum + addon.price,
    );
    return (item.price + addonsTotal) * quantity;
  }

  CartLine copyWith({
    MenuItem? item,
    int? quantity,
    List<MenuAddon>? selectedAddons,
  }) {
    return CartLine(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      selectedAddons: selectedAddons ?? this.selectedAddons,
    );
  }
}

class CartState {
  const CartState({this.lines = const [], this.appliedPromo, this.tip = 3});

  final List<CartLine> lines;
  final Promotion? appliedPromo;
  final double tip;

  int get count => lines.fold(0, (sum, line) => sum + line.quantity);
  double get subtotal => lines.fold(0, (sum, line) => sum + line.lineTotal);
  double get deliveryFee => subtotal > 35 || subtotal == 0 ? 0 : 3.99;
  double get taxes => subtotal * .0825;
  double get discount => subtotal * (appliedPromo?.discount ?? 0);
  double get total => subtotal + deliveryFee + taxes + tip - discount;

  CartState copyWith({
    List<CartLine>? lines,
    Promotion? appliedPromo,
    bool clearPromo = false,
    double? tip,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      appliedPromo: clearPromo ? null : appliedPromo ?? this.appliedPromo,
      tip: tip ?? this.tip,
    );
  }
}

class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.rating,
    required this.phone,
  });

  final String id;
  final String name;
  final String vehicle;
  final double rating;
  final String phone;
}

class Order {
  const Order({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.total,
    required this.stage,
    required this.etaMinutes,
    required this.createdLabel,
  });

  final String id;
  final String restaurantName;
  final List<CartLine> items;
  final double total;
  final OrderStage stage;
  final int etaMinutes;
  final String createdLabel;
}

class OrderTracking {
  const OrderTracking({
    required this.stage,
    required this.progress,
    required this.etaMinutes,
    required this.driver,
    required this.routeLabel,
    required this.driverOffset,
  });

  final OrderStage stage;
  final double progress;
  final int etaMinutes;
  final Driver driver;
  final String routeLabel;
  final double driverOffset;
}

class Review {
  const Review({
    required this.author,
    required this.rating,
    required this.text,
    required this.reactions,
  });

  final String author;
  final double rating;
  final String text;
  final int reactions;
}

class Reward {
  const Reward({
    required this.points,
    required this.tier,
    required this.nextRewardLabel,
    required this.progress,
  });

  final int points;
  final String tier;
  final String nextRewardLabel;
  final double progress;
}

class FoodNotification {
  const FoodNotification({
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;
}

abstract class FoodRepository {
  Future<List<Restaurant>> fetchRestaurants();
  Future<List<Promotion>> fetchPromotions();
  Future<List<Order>> fetchOrders();
  Future<Reward> fetchReward();
  Future<List<FoodNotification>> fetchNotifications();
  Future<List<String>> fetchAiSuggestions(String preference);
  Stream<OrderTracking> watchLiveOrder();
}
