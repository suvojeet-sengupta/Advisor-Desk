import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_state.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

import 'package:advisor_desk/data/datasources/ad_service.dart'; // Import AdService

class AddCSATEntryScreen extends StatelessWidget {
  final CSATEntry? entryToEdit;

  const AddCSATEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddCSATEntryBloc(
        repository: context.read<PerformanceRepository>(),
        adService: context.read<AdService>(), // Provide AdService
      )..add(InitializeCSATEntry(entry: entryToEdit)), // Dispatch InitializeCSATEntry event
      child: const AddCSATEntryView(),
    );
  }
}

class AddCSATEntryView extends StatefulWidget {
  const AddCSATEntryView({Key? key}) : super(key: key);

  @override
  State<AddCSATEntryView> createState() => _AddCSATEntryViewState();
}

class _AddCSATEntryViewState extends State<AddCSATEntryView> {
  late final TextEditingController _t2CountController;
  late final TextEditingController _b2CountController;
  late final TextEditingController _nCountController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AddCSATEntryBloc>().state;
    _t2CountController = TextEditingController(text: state.isUpdate ? state.t2Count.toString() : '');
    _b2CountController = TextEditingController(text: state.isUpdate ? state.b2Count.toString() : '');
    _nCountController = TextEditingController(text: state.isUpdate ? state.nCount.toString() : '');
  }

  @override
  void dispose() {
    _t2CountController.dispose();
    _b2CountController.dispose();
    _nCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCSATEntryBloc, AddCSATEntryState>(
      listener: (context, state) {
        final language = context.read<LanguageCubit>().state;
        if (state.status == AddCSATEntryStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isDelete 
                ? AppStrings.get(language, 'csat_deleted_success') 
                : AppStrings.get(language, 'csat_added_success')),
              backgroundColor: AppColors.accentGreen,
            ),
          );
          Navigator.of(context).pop(true); // Go back to the previous screen
        } else if (state.status == AddCSATEntryStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppStrings.get(language, 'failed_save_csat')),
              backgroundColor: AppColors.accentRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final language = context.watch<LanguageCubit>().state;
        return Scaffold(
          appBar: CustomAppBar(
            title: state.isUpdate ? AppStrings.get(language, 'edit_csat_entry') : AppStrings.get(language, 'add_csat_entry'),
          ),
          body: state.status == AddCSATEntryStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Section
                      _buildSectionTitle(context, AppStrings.get(language, 'date_label')),
                      const SizedBox(height: 8),
                      CustomCard(
                        child: InkWell(
                          onTap: () => _selectDate(context, state.date),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.outline),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('dd MMM yyyy').format(state.date),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // T2 Count Section
                      CustomFormField(
                        label: AppStrings.get(language, 't2_count_label'),
                        hintText: AppStrings.get(language, 'enter_t2_hint'),
                        icon: Icons.thumb_up,
                        controller: _t2CountController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          context.read<AddCSATEntryBloc>().add(T2CountChanged(count: int.tryParse(value) ?? 0));
                        },
                      ),
                      const SizedBox(height: 16),

                      // B2 Count Section
                      CustomFormField(
                        label: AppStrings.get(language, 'b2_count_label'),
                        hintText: AppStrings.get(language, 'enter_b2_hint'),
                        icon: Icons.thumb_down,
                        controller: _b2CountController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          context.read<AddCSATEntryBloc>().add(B2CountChanged(count: int.tryParse(value) ?? 0));
                        },
                      ),
                      const SizedBox(height: 16),

                      // N Count Section
                      CustomFormField(
                        label: AppStrings.get(language, 'n_count_label'),
                        hintText: AppStrings.get(language, 'enter_n_hint'),
                        icon: Icons.remove,
                        controller: _nCountController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          context.read<AddCSATEntryBloc>().add(NCountChanged(count: int.tryParse(value) ?? 0));
                        },
                      ),
                      const SizedBox(height: 24),

                      // Preview Section
                      if (state.t2Count > 0 || state.b2Count > 0 || state.nCount > 0) ...[
                        _buildSectionTitle(context, AppStrings.get(language, 'preview_section')),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildPreviewRow(AppStrings.get(language, 'total_survey_hits'), '${state.t2Count + state.b2Count + state.nCount}'),
                              const Divider(),
                              _buildPreviewRow(AppStrings.get(language, 't2_score'), '${_calculateScore(state.t2Count, state).toStringAsFixed(2)}%'),
                              _buildPreviewRow(AppStrings.get(language, 'b2_score'), '${_calculateScore(state.b2Count, state).toStringAsFixed(2)}%'),
                              _buildPreviewRow(AppStrings.get(language, 'n_score'), '${_calculateScore(state.nCount, state).toStringAsFixed(2)}%'),
                              const Divider(),
                              _buildPreviewRow(
                                AppStrings.get(language, 'csat_percentage'),
                                '${_calculateCSAT(state).toStringAsFixed(2)}%',
                                isHighlight: true,
                                color: _calculateCSAT(state) >= 60 ? Colors.green : Theme.of(context).colorScheme.error,
                              ),
                              if (_calculateCSAT(state) < 60)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Theme.of(context).colorScheme.error,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            AppStrings.get(language, 'csat_needs_improvement'),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.error,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedButton(
                          onPressed: state.status == AddCSATEntryStatus.loading ? null : () {
                            context.read<AddCSATEntryBloc>().add(const SubmitCSATEntry());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(state.isUpdate ? Icons.update : Icons.add),
                              const SizedBox(width: 8),
                              Text(state.isUpdate ? AppStrings.get(language, 'update_csat_btn') : AppStrings.get(language, 'save_csat_btn')),
                            ],
                          ),
                        ),
                      ),

                      if (state.isUpdate) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: AnimatedButton(
                            onPressed: state.status == AddCSATEntryStatus.loading ? null : () => _showDeleteConfirmationDialog(context, language),
                            backgroundColor: AppColors.secondaryBackground,
                            foregroundColor: AppColors.textPrimary,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete_outline),
                                const SizedBox(width: 8),
                                Text(AppStrings.get(language, 'delete_entry_btn')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, {bool isHighlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? (isHighlight ? Theme.of(context).colorScheme.primary : null),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateScore(int count, AddCSATEntryState state) {
    final total = state.t2Count + state.b2Count + state.nCount;
    if (total == 0) return 0.0;
    return (100 / total) * count;
  }

  double _calculateCSAT(AddCSATEntryState state) {
    return _calculateScore(state.t2Count, state) - _calculateScore(state.b2Count, state);
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      context.read<AddCSATEntryBloc>().add(CSATDateChanged(date: selectedDate));
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Language language) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          title: Text(AppStrings.get(language, 'confirm_delete_title')),
          content: Text(AppStrings.get(language, 'confirm_delete_csat_message')),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings.get(language, 'cancel')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppStrings.get(language, 'delete')),
              onPressed: () {
                context.read<AddCSATEntryBloc>().add(const DeleteCSATEntry());
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}



