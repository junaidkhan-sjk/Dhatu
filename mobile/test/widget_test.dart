import 'package:flutter_test/flutter_test.dart';
import 'package:dhatu_mobile/main.dart';

void main() {
  testWidgets('Dhatu app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DhatuApp());
    expect(find.textContaining('DHATU'), findsOneWidget);
  });
}
