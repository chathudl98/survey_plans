import 'package:flutter_test/flutter_test.dart';
import 'package:survey_plans/main.dart';

void main() {
  testWidgets('App builds root widget', (WidgetTester tester) async {
    // We don’t initialize Firebase in tests here; just ensure the widget exists.
    // In a real test you’d mock Firebase.initializeApp().
    await tester.pumpWidget(const SurveyPlansApp());
    expect(find.byType(SurveyPlansApp), findsOneWidget);
  });
}
