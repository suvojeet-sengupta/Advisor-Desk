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
                : (state.isUpdate ? AppStrings.get(language, 'csat_updated_success') : AppStrings.get(language, 'csat_added_success'))),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state.status == AddCSATEntryStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? AppStrings.get(language, 'failed_save_csat')),
              backgroundColor: Theme.of(context).colorScheme.error,
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Section
                      _buildSectionTitle(context, AppStrings.get(language, 'date_label')),
                      const SizedBox(height: 12),
                      CustomCard(
                        onTap: () => _selectDate(context, state.date),
                        padding: EdgeInsets.zero,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                DateFormat('dd MMMM yyyy').format(state.date),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Icon(Icons.edit_calendar_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Survey Hits Section
                      _buildSectionTitle(context, AppStrings.get(language, 'survey_hits_section')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              label: AppStrings.get(language, 't2_count_label'),
                              hintText: '0',
                              icon: Icons.sentiment_very_satisfied_rounded,
                              controller: _t2CountController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AddCSATEntryBloc>().add(T2CountChanged(count: int.tryParse(value) ?? 0));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomFormField(
                              label: AppStrings.get(language, 'nCount_label') ?? 'N Count',
                              hintText: '0',
                              icon: Icons.sentiment_neutral_rounded,
                              controller: _nCountController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AddCSATEntryBloc>().add(NCountChanged(count: int.tryParse(value) ?? 0));
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomFormField(
                              label: AppStrings.get(language, 'b2_count_label'),
                              hintText: '0',
                              icon: Icons.sentiment_very_dissatisfied_rounded,
                              controller: _b2CountController,
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                context.read<AddCSATEntryBloc>().add(B2CountChanged(count: int.tryParse(value) ?? 0));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Preview Section
                      if (state.t2Count > 0 || state.b2Count > 0 || state.nCount > 0) ...[
                        _buildSectionTitle(context, AppStrings.get(language, 'preview_section')),
                        const SizedBox(height: 12),
                        CustomCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildPreviewRow(AppStrings.get(language, 'total_survey_hits'), '${state.t2Count + state.b2Count + state.nCount}'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 1),
                              ),
                              _buildPreviewRow(AppStrings.get(language, 't2_score'), '${_calculateScore(state.t2Count, state).toStringAsFixed(1)}%'),
                              _buildPreviewRow(AppStrings.get(language, 'n_score') ?? 'N Score', '${_calculateScore(state.nCount, state).toStringAsFixed(1)}%'),
                              _buildPreviewRow(AppStrings.get(language, 'b2_score'), '${_calculateScore(state.b2Count, state).toStringAsFixed(1)}%'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 1),
                              ),
                              _buildPreviewRow(
                                AppStrings.get(language, 'csat_percentage'),
                                '${_calculateCSAT(state).toStringAsFixed(1)}%',
                                isHighlight: true,
                                color: _calculateCSAT(state) >= 60 ? Colors.greenAccent : Theme.of(context).colorScheme.error,
                              ),
                              if (_calculateCSAT(state) < 60)
                                Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.error.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.error, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          AppStrings.get(language, 'csat_needs_improvement'),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.error,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
                              Icon(state.isUpdate ? Icons.published_with_changes_rounded : Icons.save_rounded),
                              const SizedBox(width: 10),
                              Text(
                                state.isUpdate ? AppStrings.get(language, 'update_csat_btn') : AppStrings.get(language, 'save_csat_btn'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (state.isUpdate) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: state.status == AddCSATEntryStatus.loading ? null : () => _showDeleteConfirmationDialog(context, language),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete_sweep_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(AppStrings.get(language, 'delete_entry_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
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
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
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



