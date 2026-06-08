import 'package:flutter_test/flutter_test.dart';
import 'package:somalia_food_hub/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SomaliaFoodHub());
    expect(find.byType(SomaliaFoodHub), findsOneWidget);
  });
}
