import 'package:flutter_test/flutter_test.dart';
import 'package:studyspace/main.dart';

void main() {
  testWidgets('StudySpace smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StudySpaceApp());
  });
}