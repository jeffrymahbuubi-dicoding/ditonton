import 'package:about/presentation/pages/about_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('AboutPage should show the description and the logo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));

    expect(find.textContaining('Ditonton merupakan'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('AboutPage back button should pop the page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPage), findsNothing);
  });
}
