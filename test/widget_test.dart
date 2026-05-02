import 'package:flutter_test/flutter_test.dart';

import 'package:semester_project_app/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SolarApp());
    expect(find.byType(SolarApp), findsOneWidget);
  });
}
