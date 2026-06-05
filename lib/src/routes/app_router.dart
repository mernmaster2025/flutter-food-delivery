import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth_screen.dart';
import '../screens/cart_checkout_screens.dart';
import '../screens/discovery_screens.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/supporting_screens.dart';
import '../screens/tracking_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoveryScreen(),
      ),
      GoRoute(
        path: '/restaurant/:id',
        builder: (context, state) =>
            RestaurantDetailsScreen(restaurantId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/food/:id',
        builder: (context, state) =>
            FoodDetailsScreen(itemId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (context, state) => const CheckoutSuccessScreen(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const TrackingScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/promotions',
        builder: (context, state) => const PromotionsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/assistant',
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
