import 'package:core/styles/colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drawer theme and color scheme should use the app colors', () {
    expect(kDrawerTheme.backgroundColor, isNotNull);
    expect(kColorScheme.primary, kMikadoYellow);
    expect(kColorScheme.secondary, kPrussianBlue);
    expect(kColorScheme.surface, kRichBlack);
  });
}
