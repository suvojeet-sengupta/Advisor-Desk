import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/models/dashboard_models.dart';

class DashboardCustomizationCubit extends Cubit<DashboardCustomization> {
  static const String _prefsKey = 'dashboard_customization';

  DashboardCustomizationCubit() : super(const DashboardCustomization()) {
    _loadCustomization();
  }

  Future<void> _loadCustomization() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        emit(DashboardCustomization.fromJson(jsonMap));
      } catch (e) {
        // Handle parsing errors, maybe reset to default
        print('Error loading dashboard customization: $e');
        emit(const DashboardCustomization());
      }
    } else {
      // If no customization saved, emit default
      emit(const DashboardCustomization());
    }
  }

  Future<void> updateVisibleSections(List<DashboardSection> newSections) async {
    final updatedCustomization = state.copyWith(visibleSections: newSections);
    emit(updatedCustomization);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(updatedCustomization.toJson()));
  }

  // You can add more methods here for reordering, etc.
}
