import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/models/dashboard_models.dart';

/// A [Cubit] that manages the customization of the dashboard.
///
/// This class handles loading and saving the user's dashboard layout preferences,
/// such as which sections are visible.
class DashboardCustomizationCubit extends Cubit<DashboardCustomization> {
  static const String _prefsKey = 'dashboard_customization';

  /// Creates a new instance of [DashboardCustomizationCubit].
  ///
  /// It initializes with a default layout and then loads the saved customization.
  DashboardCustomizationCubit() : super(const DashboardCustomization()) {
    _loadCustomization();
  }

  /// Loads the saved dashboard customization from [SharedPreferences].
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

  /// Updates the visible sections of the dashboard and saves the changes.
  ///
  /// The [newSections] list contains the sections that should be visible.
  Future<void> updateVisibleSections(List<DashboardSection> newSections) async {
    final updatedCustomization = state.copyWith(visibleSections: newSections);
    emit(updatedCustomization);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(updatedCustomization.toJson()));
  }

  // You can add more methods here for reordering, etc.
}
