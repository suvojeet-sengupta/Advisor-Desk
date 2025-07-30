import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class DashboardCustomization extends Equatable {
  final List<DashboardSection> visibleSections;

  const DashboardCustomization({
    this.visibleSections = const [
      DashboardSection.monthlySummary,
      DashboardSection.monthlyGoals,
      DashboardSection.csatPerformance,
      DashboardSection.cqPerformance,
      DashboardSection.salaryDetails,
      DashboardSection.dailyEntries,
    ],
  });

  DashboardCustomization copyWith({
    List<DashboardSection>? visibleSections,
  }) {
    return DashboardCustomization(
      visibleSections: visibleSections ?? this.visibleSections,
    );
  }

  // Convert to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'visibleSections': visibleSections.map((e) => e.index).toList(),
    };
  }

  // Create from JSON for SharedPreferences
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
