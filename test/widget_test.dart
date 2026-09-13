import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_task_manager/main.dart';

void main() {
  testWidgets('App renders AuthStateContainer', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });
}
