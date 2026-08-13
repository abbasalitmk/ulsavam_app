import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ulsavam_app/features/events/providers/events_provider.dart';
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

  test('events filter uses value-based equality to prevent duplicate fetches', () {
    const left = EventsFilter(district: 'kozhikode', category: 'temple', verifiedOnly: false);
    const right = EventsFilter(district: 'kozhikode', category: 'temple', verifiedOnly: false);

    expect(left, equals(right));
    expect(left.hashCode, equals(right.hashCode));
  });
}
