import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/models/dashboard_models.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/features/dashboard/cubit/dashboard_customization_cubit.dart';

class CustomizeDashboardScreen extends StatelessWidget {
  const CustomizeDashboardScreen({Key? key}) : super(key: key);

  String _getSectionTitle(DashboardSection section) {
    switch (section) {
      case DashboardSection.monthlySummary:
        return 'Monthly Summary Cards';
      case DashboardSection.monthlyGoals:
        return 'Monthly Goals';
      case DashboardSection.csatPerformance:
        return 'CSAT Performance';
      case DashboardSection.cqPerformance:
        return 'CQ Performance';
      case DashboardSection.salaryDetails:
        return 'Salary Details';
      case DashboardSection.dailyEntries:
        return 'Daily Entries';
      case DashboardSection.performanceChart:
        return 'Performance Chart';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Customize Dashboard'),
      body: BlocBuilder<DashboardCustomizationCubit, DashboardCustomization>(
        builder: (context, customizationState) {
          final List<DashboardSection> currentVisibleSections = List.from(customizationState.visibleSections);

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: currentVisibleSections.length, // Only reorder visible sections
            itemBuilder: (context, index) {
              final section = currentVisibleSections[index]; // Get section from visible list

              return Card(
                key: ValueKey(section.index), // Unique key for reordering
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: CheckboxListTile(
                  title: Text(_getSectionTitle(section)),
                  value: true, // Always true for visible sections
                  onChanged: (bool? newValue) {
                    if (newValue != null && !newValue) {
                      // If unchecked, remove from visible sections
                      List<DashboardSection> updatedSections = List.from(currentVisibleSections);
                      updatedSections.remove(section);
                      context.read<DashboardCustomizationCubit>().updateVisibleSections(updatedSections);
                    }
                  },
                ),
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              List<DashboardSection> updatedSections = List.from(currentVisibleSections);
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final DashboardSection movedSection = updatedSections.removeAt(oldIndex);
              updatedSections.insert(newIndex, movedSection);
              context.read<DashboardCustomizationCubit>().updateVisibleSections(updatedSections);
            },
          );
        },
      ),
    );
  }
}
