import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/core/models/dashboard_models.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/presentation/features/dashboard/cubit/dashboard_customization_cubit.dart';

class CustomizeDashboardScreen extends StatelessWidget {
  const CustomizeDashboardScreen({Key? key}) : super(key: key);

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: reorderableList.length,
                  itemBuilder: (context, index) {
                    final section = reorderableList[index];
                    final isVisible = visibleSections.contains(section);

                    return Container(
                      key: ValueKey(section),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.05),
                             blurRadius: 15,
                             offset: const Offset(0, 5),
                           ),
                         ],
                      ),
                      child: CheckboxListTile(
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          _getSectionTitle(section),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isVisible ? Theme.of(context).textTheme.titleMedium?.color : Colors.grey,
                          ),
                        ),
                        secondary: ReorderableDragStartListener(
                          index: index,
                          child: Icon(Icons.drag_indicator_rounded, color: Theme.of(context).colorScheme.primary.withOpacity(isVisible ? 1 : 0.5)),
                        ),
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

                    final reorderedList = List<DashboardSection>.from(reorderableList);
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
                padding: const EdgeInsets.all(24.0),
                child: AnimatedButton(
                  onPressed: () {
                    context
                        .read<DashboardCustomizationCubit>()
                        .updateVisibleSections(
                            const DashboardCustomization().visibleSections);
                  },
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  child: Text(
                    'Reset to Default',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
