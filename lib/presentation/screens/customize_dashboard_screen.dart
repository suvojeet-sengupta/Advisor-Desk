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

          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: DashboardSection.values.length, // Show all sections
                  itemBuilder: (context, index) {
                    final section = DashboardSection.values[index];
                    final isVisible = customizationState.visibleSections.contains(section);

                    return Card(
                      key: ValueKey(section.index), // Unique key for reordering
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CheckboxListTile(
                        title: Text(_getSectionTitle(section)),
                        value: isVisible,
                        onChanged: (bool? newValue) {
                          List<DashboardSection> updatedSections = List.from(customizationState.visibleSections);
                          if (newValue != null) {
                            if (newValue) {
                              // Add to visible sections, maintaining order if possible
                              updatedSections.add(section);
                              // Sort to maintain a consistent order for newly added items
                              updatedSections.sort((a, b) => DashboardSection.values.indexOf(a).compareTo(DashboardSection.values.indexOf(b)));
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
                    // Reorder only the visible sections
                    List<DashboardSection> updatedSections = List.from(customizationState.visibleSections);
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final DashboardSection movedSection = updatedSections.removeAt(oldIndex);
                    updatedSections.insert(newIndex, movedSection);
                    context.read<DashboardCustomizationCubit>().updateVisibleSections(updatedSections);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<DashboardCustomizationCubit>().updateVisibleSections(const DashboardCustomization().visibleSections); // Reset to default
                  },
                  child: const Text('Reset to Default'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
