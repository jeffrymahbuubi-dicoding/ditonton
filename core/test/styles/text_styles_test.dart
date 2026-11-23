import 'package:core/styles/text_styles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('text styles should have the sizes of the app theme', () {
    expect(kHeading5.fontSize, 23);
    expect(kHeading6.fontSize, 19);
    expect(kSubtitle.fontSize, 15);
    expect(kBodyText.fontSize, 13);
  });

  test('text theme should map the styles', () {
    expect(kTextTheme.headlineMedium, kHeading5);
    expect(kTextTheme.headlineSmall, kHeading6);
    expect(kTextTheme.labelMedium, kSubtitle);
    expect(kTextTheme.bodyMedium, kBodyText);
  });
}
