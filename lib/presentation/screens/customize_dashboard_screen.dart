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
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Customize Dashboard'),
      body: BlocBuilder<DashboardCustomizationCubit, DashboardCustomization>(
        builder: (context, customizationState) {
          final visibleSections = customizationState.visibleSections;
          final hiddenSections = DashboardSection.values
              .where((section) => !visibleSections.contains(section))
              .toList();

          final reorderableList = [...visibleSections, ...hiddenSections];

          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: reorderableList.length,
                  itemBuilder: (context, index) {
                    final section = reorderableList[index];
                    final isVisible = visibleSections.contains(section);

                    return Card(
                      key: ValueKey(section),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: CheckboxListTile(
                        title: Text(_getSectionTitle(section)),
                        value: isVisible,
                        onChanged: (bool? newValue) {
                          final newVisibleSections =
                              List<DashboardSection>.from(visibleSections);
                          if (newValue == true) {
                            if (!newVisibleSections.contains(section)) {
                              newVisibleSections.add(section);
                            }
                          } else {
                            newVisibleSections.remove(section);
                          }
                          context
                              .read<DashboardCustomizationCubit>()
                              .updateVisibleSections(newVisibleSections);
                        },
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    final reorderedList =
                        List<DashboardSection>.from(reorderableList);
                    final movedSection = reorderedList.removeAt(oldIndex);
                    reorderedList.insert(newIndex, movedSection);

                    final newVisibleSections = reorderedList
                        .where((s) => visibleSections.contains(s))
                        .toList();

                    context
                        .read<DashboardCustomizationCubit>()
                        .updateVisibleSections(newVisibleSections);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<DashboardCustomizationCubit>()
                        .updateVisibleSections(
                            const DashboardCustomization().visibleSections);
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
