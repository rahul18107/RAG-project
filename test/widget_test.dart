import 'package:flutter_test/flutter_test.dart';
import 'package:studycomp/main.dart';

void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyMindApp());
    expect(find.byType(StudyMindApp), findsOneWidget);
  });
}