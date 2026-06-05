import 'dart:async';

import '../domain/foodflow_models.dart';

class MockFoodRepository implements FoodRepository {
  MockFoodRepository();

  final Driver _driver = const Driver(
    id: 'driver-maya',
    name: 'Maya Chen',
    vehicle: 'Electric Vespa',
    rating: 4.98,
    phone: '+1 555 0184',
  );

  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    await _latency();
    return mockRestaurants;
  }

  @override
  Future<List<Promotion>> fetchPromotions() async {
    await _latency();
    return mockPromotions;
  }

  @override
  Future<List<Order>> fetchOrders() async {
    await _latency();
    final velvet = mockRestaurants.first;
    final luna = mockRestaurants[1];
    return [
      Order(
        id: 'FF-1048',
        restaurantName: velvet.name,
        items: [CartLine(item: velvet.menu.first, quantity: 2)],
        total: 42.80,
        stage: OrderStage.delivered,
        etaMinutes: 0,
        createdLabel: 'Yesterday',
      ),
      Order(
        id: 'FF-1032',
        restaurantName: luna.name,
        items: [CartLine(item: luna.menu[1])],
        total: 24.25,
        stage: OrderStage.delivered,
        etaMinutes: 0,
        createdLabel: 'Last Friday',
      ),
    ];
  }

  @override
  Future<Reward> fetchReward() async {
    await _latency();
    return const Reward(
      points: 7420,
      tier: 'Platinum Bite Club',
      nextRewardLabel: '580 points to free priority delivery',
      progress: .82,
    );
  }

  @override
  Future<List<FoodNotification>> fetchNotifications() async {
    await _latency();
    return const [
      FoodNotification(
        title: 'Your chef started plating',
        body: 'Velvet Taco Lab is finishing the crispy birria set.',
        time: '2 min ago',
      ),
      FoodNotification(
        title: 'Reward unlocked',
        body: 'You earned double points on late-night bowls this week.',
        time: '1 hr ago',
      ),
      FoodNotification(
        title: 'AI pick',
        body: 'Three new high-protein lunches match your preferences.',
        time: 'Today',
      ),
    ];
  }

  @override
  Future<List<String>> fetchAiSuggestions(String preference) async {
    await _latency();
    final focus = preference.trim().isEmpty
        ? 'bright, protein-forward'
        : preference;
    return [
      'Try Luna Bowl House for a $focus meal with avocado crunch and yuzu lime.',
      'FoodFlow predicts you will like the Seoul Fire Bao because you reorder spicy citrus dishes.',
      'Tonight feels like a comfort order: truffle mac bites, sparkling lemonade, and a 24 minute ETA.',
    ];
  }

  @override
  Stream<OrderTracking> watchLiveOrder() async* {
    const stages = [
      OrderStage.confirmed,
      OrderStage.preparing,
      OrderStage.pickedUp,
      OrderStage.nearby,
      OrderStage.delivered,
    ];
    for (var i = 0; i < 24; i++) {
      final progress = i / 23;
      final stage = stages[(progress * (stages.length - 1)).floor()];
      yield OrderTracking(
        stage: stage,
        progress: progress,
        etaMinutes: (28 - (progress * 27)).ceil(),
        driver: _driver,
        routeLabel: progress < .45
            ? 'Chef is preparing your order'
            : progress < .78
            ? 'Maya is gliding through downtown'
            : 'Arriving at your door',
        driverOffset: progress,
      );
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
  }

  Future<void> _latency() {
    return Future<void>.delayed(const Duration(milliseconds: 460));
  }
}

const mockPromotions = [
  Promotion(
    id: 'promo-flash',
    title: 'Sunset Flash Deal',
    subtitle: '30% off vibrant bowls until 8 PM',
    code: 'SUNSET30',
    discount: .30,
    accentColors: [0xFFFF7A1A, 0xFFFF4F6D, 0xFFFF4FD8],
  ),
  Promotion(
    id: 'promo-vip',
    title: 'VIP Priority Week',
    subtitle: 'Free priority delivery on premium kitchens',
    code: 'FLOWVIP',
    discount: .15,
    accentColors: [0xFF8D5CFF, 0xFF35C2FF],
  ),
];

final mockRestaurants = [
  Restaurant(
    id: 'velvet-taco-lab',
    name: 'Velvet Taco Lab',
    cuisine: 'Neo Mexican',
    description: 'Chef-driven tacos, smoked salsas, and neon citrus plates.',
    rating: 4.9,
    reviewCount: 4820,
    deliveryMinutes: 18,
    distanceKm: 1.2,
    priceTier: r'$$',
    promo: '30% off with SUNSET30',
    tags: const ['Trending', 'Fast', 'Spicy', 'Rewards x2'],
    accentColors: const [0xFFFF7A1A, 0xFFFF4F6D],
    isTrending: true,
    isFavorite: true,
    menu: const [
      MenuItem(
        id: 'birria-cloud',
        restaurantId: 'velvet-taco-lab',
        name: 'Crispy Birria Cloud',
        description:
            'Slow braised beef, Oaxaca cheese, consommé pearls, pickled neon onions.',
        category: 'Popular',
        price: 15.90,
        calories: 640,
        rating: 4.96,
        prepMinutes: 12,
        accentColors: [0xFFFF7A1A, 0xFFFF4F6D],
        ingredients: [
          'Braised beef',
          'Oaxaca cheese',
          'Corn tortilla',
          'Consommé',
          'Cilantro',
        ],
        addons: [
          MenuAddon(name: 'Avocado crema', price: 1.80),
          MenuAddon(name: 'Extra consommé', price: 2.20),
        ],
        isPopular: true,
        isFavorite: true,
      ),
      MenuItem(
        id: 'mango-fire-taco',
        restaurantId: 'velvet-taco-lab',
        name: 'Mango Fire Taco',
        description:
            'Charred chicken, mango habanero glaze, lime dust, crispy shallot.',
        category: 'Featured',
        price: 12.40,
        calories: 510,
        rating: 4.88,
        prepMinutes: 10,
        accentColors: [0xFFFFC857, 0xFFFF4F6D],
        ingredients: ['Chicken', 'Mango', 'Habanero', 'Lime', 'Shallot'],
        addons: [MenuAddon(name: 'Pineapple salsa', price: 1.40)],
        isPopular: true,
        isFavorite: false,
      ),
    ],
  ),
  Restaurant(
    id: 'luna-bowl-house',
    name: 'Luna Bowl House',
    cuisine: 'Wellness Bowls',
    description: 'Color-rich bowls with adaptogenic sauces and crisp greens.',
    rating: 4.8,
    reviewCount: 3260,
    deliveryMinutes: 22,
    distanceKm: 2.4,
    priceTier: r'$$',
    promo: 'Free immunity shot',
    tags: const ['Healthy', 'Vegan', 'High protein'],
    accentColors: const [0xFF00D18F, 0xFFB8FF4D],
    isTrending: true,
    isFavorite: false,
    menu: const [
      MenuItem(
        id: 'aurora-salmon-bowl',
        restaurantId: 'luna-bowl-house',
        name: 'Aurora Salmon Bowl',
        description:
            'Miso salmon, black rice, cucumber ribbons, yuzu avocado foam.',
        category: 'Popular',
        price: 18.50,
        calories: 720,
        rating: 4.93,
        prepMinutes: 14,
        accentColors: [0xFF00D18F, 0xFF35C2FF],
        ingredients: ['Salmon', 'Black rice', 'Cucumber', 'Yuzu', 'Avocado'],
        addons: [
          MenuAddon(name: 'Extra salmon', price: 5.50),
          MenuAddon(name: 'Chili crisp', price: 1.10),
        ],
        isPopular: true,
        isFavorite: false,
      ),
      MenuItem(
        id: 'garden-lift',
        restaurantId: 'luna-bowl-house',
        name: 'Garden Lift Bowl',
        description: 'Charred broccoli, edamame, citrus tahini, puffed quinoa.',
        category: 'Plant Power',
        price: 14.80,
        calories: 560,
        rating: 4.82,
        prepMinutes: 11,
        accentColors: [0xFFB8FF4D, 0xFF00D18F],
        ingredients: ['Broccoli', 'Edamame', 'Tahini', 'Quinoa', 'Mint'],
        addons: [MenuAddon(name: 'Jammy egg', price: 2.00)],
        isPopular: false,
        isFavorite: true,
      ),
    ],
  ),
  Restaurant(
    id: 'midnight-ramen-club',
    name: 'Midnight Ramen Club',
    cuisine: 'Tokyo Comfort',
    description: 'Late-night broths, glossy noodles, and cinematic sides.',
    rating: 4.92,
    reviewCount: 5910,
    deliveryMinutes: 26,
    distanceKm: 3.1,
    priceTier: r'$$$',
    promo: 'Bundle ramen + bao',
    tags: const ['Open late', 'Comfort', 'Top rated'],
    accentColors: const [0xFF8D5CFF, 0xFF35C2FF],
    isTrending: false,
    isFavorite: true,
    menu: const [
      MenuItem(
        id: 'truffle-tonkotsu',
        restaurantId: 'midnight-ramen-club',
        name: 'Truffle Tonkotsu',
        description:
            'Silky pork broth, black garlic oil, truffle snow, jammy egg.',
        category: 'Signature',
        price: 19.20,
        calories: 830,
        rating: 4.97,
        prepMinutes: 16,
        accentColors: [0xFF8D5CFF, 0xFFFFC857],
        ingredients: [
          'Pork broth',
          'Noodles',
          'Black garlic',
          'Egg',
          'Truffle',
        ],
        addons: [MenuAddon(name: 'Extra chashu', price: 4.20)],
        isPopular: true,
        isFavorite: true,
      ),
      MenuItem(
        id: 'seoul-fire-bao',
        restaurantId: 'midnight-ramen-club',
        name: 'Seoul Fire Bao',
        description:
            'Crispy chicken, gochujang caramel, cucumber, toasted sesame.',
        category: 'Small Plates',
        price: 11.60,
        calories: 470,
        rating: 4.86,
        prepMinutes: 9,
        accentColors: [0xFFFF4F6D, 0xFFFF7A1A],
        ingredients: ['Chicken', 'Bao', 'Gochujang', 'Cucumber', 'Sesame'],
        addons: [MenuAddon(name: 'Double bao', price: 5.80)],
        isPopular: true,
        isFavorite: false,
      ),
    ],
  ),
  Restaurant(
    id: 'pastel-pizza-studio',
    name: 'Pastel Pizza Studio',
    cuisine: 'Modern Italian',
    description: 'Roman-style slices, whipped ricotta, and botanical sodas.',
    rating: 4.75,
    reviewCount: 2140,
    deliveryMinutes: 31,
    distanceKm: 4.4,
    priceTier: r'$$',
    promo: 'Second slice half off',
    tags: const ['Family', 'New', 'Vegetarian'],
    accentColors: const [0xFFFF4FD8, 0xFFFFC857],
    isTrending: false,
    isFavorite: false,
    menu: const [
      MenuItem(
        id: 'hot-honey-cloud',
        restaurantId: 'pastel-pizza-studio',
        name: 'Hot Honey Cloud Slice',
        description:
            'Crisp airy crust, soppressata, whipped ricotta, chili honey.',
        category: 'Slices',
        price: 8.90,
        calories: 420,
        rating: 4.78,
        prepMinutes: 8,
        accentColors: [0xFFFF4FD8, 0xFFFFC857],
        ingredients: [
          'Roman crust',
          'Soppressata',
          'Ricotta',
          'Honey',
          'Basil',
        ],
        addons: [MenuAddon(name: 'Burrata dip', price: 3.60)],
        isPopular: true,
        isFavorite: false,
      ),
      MenuItem(
        id: 'emerald-pesto-square',
        restaurantId: 'pastel-pizza-studio',
        name: 'Emerald Pesto Square',
        description:
            'Pistachio pesto, zucchini ribbons, lemon zest, parmesan glass.',
        category: 'Vegetarian',
        price: 9.40,
        calories: 390,
        rating: 4.74,
        prepMinutes: 8,
        accentColors: [0xFF00D18F, 0xFFB8FF4D],
        ingredients: ['Pesto', 'Zucchini', 'Lemon', 'Parmesan', 'Crust'],
        addons: [MenuAddon(name: 'Extra parmesan', price: 1.20)],
        isPopular: false,
        isFavorite: true,
      ),
    ],
  ),
];
