import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

/// A model representing the customization settings for the dashboard.
///
/// This class stores which sections are visible on the dashboard. It also provides
/// methods for serialization and deserialization to/from JSON, which is useful
/// for storing the settings in SharedPreferences.
class DashboardCustomization extends Equatable {
  /// The list of [DashboardSection]s that are currently visible on the dashboard.
  final List<DashboardSection> visibleSections;

  /// Creates a new instance of [DashboardCustomization].
  ///
  /// By default, all dashboard sections are visible.
  const DashboardCustomization({
    this.visibleSections = const [
      DashboardSection.monthlySummary,
      DashboardSection.monthlyGoals,
      DashboardSection.salaryDetails,
      DashboardSection.dailyEntries,
    ],
  });

  /// Creates a copy of this [DashboardCustomization] but with the given fields
  /// replaced with the new values.
  ///
  /// The [visibleSections] parameter is the new list of visible sections.
  DashboardCustomization copyWith({
    List<DashboardSection>? visibleSections,
  }) {
    return DashboardCustomization(
      visibleSections: visibleSections ?? this.visibleSections,
    );
  }

  /// Converts this [DashboardCustomization] object into a JSON format.
  ///
  /// This is useful for storing the object in local storage like SharedPreferences.
  /// Returns a `Map<String, dynamic>` representing the object.
  Map<String, dynamic> toJson() {
    return {
      'visibleSections': visibleSections.map((e) => e.index).toList(),
    };
  }

  /// Creates a [DashboardCustomization] object from a JSON map.
  ///
  /// The [json] parameter is a `Map<String, dynamic>` that represents the object.
  factory DashboardCustomization.fromJson(Map<String, dynamic> json) {
    return DashboardCustomization(
      visibleSections: (json['visibleSections'] as List<dynamic>)
          .map((e) => DashboardSection.values[e as int])
          .toList(),
    );
  }

  @override
  List<Object?> get props => [visibleSections];
}
