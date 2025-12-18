import 'package:advisor_desk/core/localization/language_cubit.dart';
import 'package:advisor_desk/core/localization/strings_en.dart';
import 'package:advisor_desk/core/localization/strings_hinglish.dart';

class AppStrings {
  static String getGreeting(Language language, int hour) {
    if (language == Language.hinglish) {
      if (hour < 12) return 'Good Morning! Chai pi li? ☕';
      if (hour < 17) return 'Good Afternoon! Lunch ho gaya? 🍛';
      if (hour < 21) return 'Good Evening! Shift kaisi chal rahi hai? 🌆';
      return 'Good Night! So jao ab 😴';
    } else {
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      if (hour < 21) return 'Good Evening';
      return 'Good Night';
    }
  }

  static String get(Language language, String key) {
    if (language == Language.hinglish) {
      return StringsHinglish.data[key] ?? StringsEn.data[key] ?? key;
    }
    return StringsEn.data[key] ?? key;
  }
}
