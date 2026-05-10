import 'package:bodyfitclubtt/features/settings/data/settings_service.dart';
import 'package:bodyfitclubtt/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await SettingsService.instance.load();

    await tester.pumpWidget(MyApp(settingsService: SettingsService.instance));

    expect(find.text('Body Fit Club TT'), findsWidgets);
  });
}
