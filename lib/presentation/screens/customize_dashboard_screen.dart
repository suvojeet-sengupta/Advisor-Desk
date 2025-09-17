import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/models/dashboard_models.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/features/dashboard/cubit/dashboard_customization_cubit.dart';

/// A screen that allows users to customize the layout of their dashboard.
///
/// Users can reorder dashboard sections and toggle their visibility.
/// The state of the customization is managed by the [DashboardCustomizationCubit].
class CustomizeDashboardScreen extends StatelessWidget {
  /// Creates a [CustomizeDashboardScreen].
  const CustomizeDashboardScreen({super.key});

  /// Returns a user-friendly title for a given [DashboardSection].
  String _getSectionTitle(DashboardSection section) {
    switch (section) {
      case DashboardSection.monthlySummary:
        return 'Monthly Summary Cards';
      case DashboardSection.monthlyGoals:
        return 'Monthly Goals';
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
          // Combine visible and hidden sections for the reorderable list.
          final allSections = DashboardSection.values.toList();
          final reorderableList = List<DashboardSection>.from(visibleSections)
            ..addAll(allSections.where((s) => !visibleSections.contains(s)));

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
                      child: SwitchListTile(
                        title: Text(_getSectionTitle(section)),
                        value: isVisible,
                        onChanged: (bool? newValue) {
                          context
                              .read<DashboardCustomizationCubit>()
                              .toggleSectionVisibility(section);
                        },
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    context
                        .read<DashboardCustomizationCubit>()
                        .reorderSections(oldIndex, newIndex);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<DashboardCustomizationCubit>()
                        .resetToDefault();
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
