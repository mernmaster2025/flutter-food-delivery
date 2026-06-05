import 'package:flutter_test/flutter_test.dart';
import 'package:foodflow/src/data/mock_food_repository.dart';
import 'package:foodflow/src/domain/foodflow_models.dart';

void main() {
  test(
    'mock repository exposes realistic app data and tracking updates',
    () async {
      final repository = MockFoodRepository();

      final restaurants = await repository.fetchRestaurants();
      final promotions = await repository.fetchPromotions();
      final firstTracking = await repository.watchLiveOrder().first;

      expect(restaurants, isNotEmpty);
      expect(restaurants.first.menu, isNotEmpty);
      expect(promotions.first.discount, greaterThan(0));
      expect(firstTracking.stage, OrderStage.confirmed);
    },
  );
}
