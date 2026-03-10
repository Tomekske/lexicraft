import 'package:flutter_test/flutter_test.dart';
import 'package:lexicraft/main.dart';

void main() {
  testWidgets('Lexicraft app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LexicraftApp());

    // Verify that our app starts with Lexicraft title
    expect(find.text('LEXICRAFT'), findsOneWidget);
  });
}
