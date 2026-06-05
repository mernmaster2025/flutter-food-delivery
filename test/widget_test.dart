import 'package:flutter_test/flutter_test.dart';
import 'package:foodflow/main.dart';

void main() {
  testWidgets('FoodFlow launches into the premium splash screen', (
    tester,
  ) async {
    await tester.pumpWidget(const FoodFlowBootstrap());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('FoodFlow'), findsOneWidget);
    expect(find.text('Premium delivery in motion'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Crave-worthy discovery'), findsOneWidget);
  });
}
