import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ulsavam_app/main.dart';

void main() {
  testWidgets('Ulsavam App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UlsavamApp(),
      ),
    );

    expect(find.text('Ulsavam'), findsOneWidget);
  });
}
