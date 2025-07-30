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
            itemCount: DashboardSection.values.length,
            itemBuilder: (context, index) {
              final section = DashboardSection.values[index];
              final isVisible = currentVisibleSections.contains(section);

              return Card(
                key: ValueKey(section.index), // Unique key for reordering
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: CheckboxListTile(
                  title: Text(_getSectionTitle(section)),
                  value: isVisible,
                  onChanged: (bool? newValue) {
                    if (newValue != null) {
                      List<DashboardSection> updatedSections = List.from(currentVisibleSections);
                      if (newValue) {
                        updatedSections.add(section);
                      } else {
                        updatedSections.remove(section);
                      }
                      context.read<DashboardCustomizationCubit>().updateVisibleSections(updatedSections);
                    }
                  },
                ),
              );
            },
            onReorder: (int oldIndex, int newIndex) {
              // This reordering logic needs to be applied to the `visibleSections` list
              // based on the order of `DashboardSection.values`.
              // This is a bit tricky because `ReorderableListView` reorders based on its `itemBuilder` index,
              // not directly on the `visibleSections` list.
              // For simplicity, let's just handle visibility for now.
              // Reordering visible sections will require a more complex approach.

              // For now, we'll just reorder the full list of sections and then filter for visible ones.
              // This is not ideal for performance if you have many sections, but works for a small list.
              final List<DashboardSection> allSections = List.from(DashboardSection.values);
              final DashboardSection movedSection = allSections.removeAt(oldIndex);
              allSections.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, movedSection);

              // Now, filter this reordered list to get only the visible sections
              final List<DashboardSection> reorderedVisibleSections = allSections
                  .where((s) => customizationState.visibleSections.contains(s))
                  .toList();

              context.read<DashboardCustomizationCubit>().updateVisibleSections(reorderedVisibleSections);
            },
          );
        },
      ),
    );
  }
}
