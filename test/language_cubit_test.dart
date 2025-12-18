import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LanguageCubit', () {
    test('initial state is English', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = LanguageCubit();
      await Future.delayed(Duration.zero); // Wait for async init
      expect(cubit.state, Language.english);
    });

    test('loads Hinglish from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'is_hinglish': true});
      final cubit = LanguageCubit();
      await Future.delayed(Duration.zero);
      expect(cubit.state, Language.hinglish);
    });

    test('toggles language and saves preference', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = LanguageCubit();
      
      await cubit.setLanguage(Language.hinglish);
      expect(cubit.state, Language.hinglish);
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_hinglish'), true);

      await cubit.setLanguage(Language.english);
      expect(cubit.state, Language.english);
      expect(prefs.getBool('is_hinglish'), false);
    });
  });
}
