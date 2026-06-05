import 'package:flutter_test/flutter_test.dart';
import 'package:foodflow/src/data/mock_food_repository.dart';
import 'package:foodflow/src/state/foodflow_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('cart controller adds, increments, discounts, and clears items', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final item = mockRestaurants.first.menu.first;
    final promo = mockPromotions.first;

    container.read(cartProvider.notifier).add(item);
    container.read(cartProvider.notifier).increment(item.id);
    container.read(cartProvider.notifier).applyPromo(promo);

    final cart = container.read(cartProvider);
    expect(cart.count, 2);
    expect(cart.subtotal, item.price * 2);
    expect(cart.discount, cart.subtotal * promo.discount);
    expect(cart.total, greaterThan(0));

    container.read(cartProvider.notifier).clear();
    expect(container.read(cartProvider).lines, isEmpty);
  });
}
