import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Language { english, hinglish }

class LanguageCubit extends Cubit<Language> {
  LanguageCubit() : super(Language.english) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final isHinglish = prefs.getBool('is_hinglish') ?? false;
    emit(isHinglish ? Language.hinglish : Language.english);
  }

  Future<void> setLanguage(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_hinglish', language == Language.hinglish);
    emit(language);
  }
}
