import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_csat_entry_state.dart';

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
        if (state.status == AddCSATEntryStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isDelete ? 'CSAT Entry deleted successfully!' : 'CSAT Entry saved successfully!'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
          Navigator.of(context).pop(true); // Go back to the previous screen
        } else if (state.status == AddCSATEntryStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to save CSAT entry.'),
              backgroundColor: AppColors.accentRed,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
            title: state.isUpdate ? 'Edit CSAT Entry' : 'Add CSAT Entry',
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
                      _buildSectionTitle(context, 'Date'),
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
                        label: 'T2 Count (Positive Feedback)',
                        hintText: 'Enter T2 count',
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
                        label: 'B2 Count (Negative Feedback)',
                        hintText: 'Enter B2 count',
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
                        label: 'N Count (Neutral Feedback)',
                        hintText: 'Enter N count',
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
                        _buildSectionTitle(context, 'Preview'),
                        const SizedBox(height: 8),
                        CustomCard(
                          child: Column(
                            children: [
                              _buildPreviewRow('Total Survey Hits', '${state.t2Count + state.b2Count + state.nCount}'),
                              const Divider(),
                              _buildPreviewRow('T2 Score', '${_calculateScore(state.t2Count, state).toStringAsFixed(2)}%'),
                              _buildPreviewRow('B2 Score', '${_calculateScore(state.b2Count, state).toStringAsFixed(2)}%'),
                              _buildPreviewRow('N Score', '${_calculateScore(state.nCount, state).toStringAsFixed(2)}%'),
                              const Divider(),
                              _buildPreviewRow(
                                'CSAT Percentage',
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
                                            'CSAT below 60% - Needs Improvement',
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
                        child: CustomButton(
                          text: state.isUpdate ? 'Update CSAT Entry' : 'Add CSAT Entry',
                          onPressed: state.status == AddCSATEntryStatus.loading ? null : () {
                            context.read<AddCSATEntryBloc>().add(const SubmitCSATEntry());
                          },
                          icon: state.isUpdate ? Icons.update : Icons.add,
                        ),
                      ),

                      if (state.isUpdate) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'Delete Entry',
                            onPressed: state.status == AddCSATEntryStatus.loading ? null : () => _showDeleteConfirmationDialog(context),
                            isPrimary: false,
                            icon: Icons.delete_outline,
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
          shape: Theme.of(context).dialogTheme.shape,
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this CSAT entry? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
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



