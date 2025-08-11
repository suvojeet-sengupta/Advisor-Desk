import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_state.dart';

class AddCQEntryScreen extends StatelessWidget {
  final CQEntry? entryToEdit;

  const AddCQEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddCQEntryBloc(
        repository: context.read<PerformanceRepository>(),
      )..add(InitializeCQEntry(entry: entryToEdit)),
      child: const AddCQEntryView(),
    );
  }
}

class AddCQEntryView extends StatefulWidget {
  const AddCQEntryView({Key? key}) : super(key: key);

  @override
  State<AddCQEntryView> createState() => _AddCQEntryViewState();
}

class _AddCQEntryViewState extends State<AddCQEntryView> {
  late final TextEditingController _percentageController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AddCQEntryBloc>().state;
    _percentageController = TextEditingController(text: state.isUpdate ? state.percentage.toString() : '');
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddCQEntryBloc, AddCQEntryState>(
      listener: (context, state) {
        if (state.status == AddCQEntryStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.isDelete
                      ? 'CQ entry deleted successfully!'
                      : (state.isUpdate
                          ? 'CQ entry updated successfully!'
                          : 'CQ entry added successfully!'),
                ),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            );
          Navigator.pop(context, true);
        } else if (state.status == AddCQEntryStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to save entry'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: context.watch<AddCQEntryBloc>().state.isUpdate ? 'Edit CQ Entry' : 'Add CQ Entry',
        ),
        body: BlocBuilder<AddCQEntryBloc, AddCQEntryState>(
          builder: (context, state) {
            if (state.status == AddCQEntryStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Section
                  _buildSectionTitle(context, 'Audit Date'),
                  const SizedBox(height: 8),
                  CustomCard(
                    child: InkWell(
                      onTap: () => _selectDate(context, state.auditDate),
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
                              DateFormat('dd MMM yyyy').format(state.auditDate),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CQ Percentage Section
                  CustomFormField(
                    label: 'Call Quality Percentage',
                    hintText: 'Enter CQ percentage (0-100)',
                    icon: Icons.assessment,
                    controller: _percentageController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    suffixText: '%',
                    onChanged: (value) {
                      context.read<AddCQEntryBloc>().add(CQPercentageChanged(percentage: double.tryParse(value) ?? 0.0));
                    },
                  ),
                  const SizedBox(height: 24),

                  // Preview Section
                  if (state.percentage > 0) ...[
                    _buildSectionTitle(context, 'Preview'),
                    const SizedBox(height: 8),
                    CustomCard(
                      child: Column(
                        children: [
                          _buildPreviewRow('CQ Percentage', '${state.percentage.toStringAsFixed(2)}%'),
                          const Divider(),
                          _buildPreviewRow(
                            'Quality Rating',
                            _getQualityRating(state.percentage),
                            isHighlight: true,
                            color: _getQualityColor(state.percentage),
                          ),
                          if (state.percentage < 80)
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
                                        'CQ below 80% - Needs Improvement',
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
                      text: state.isUpdate ? 'Update CQ Entry' : 'Add CQ Entry',
                      onPressed: state.status == AddCQEntryStatus.loading ? null : () {
                        context.read<AddCQEntryBloc>().add(const SubmitCQEntry());
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
                        onPressed: state.status == AddCQEntryStatus.loading ? null : () => _showDeleteConfirmationDialog(context),
                        isPrimary: false,
                        icon: Icons.delete_outline,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
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

  String _getQualityRating(double percentage) {
    if (percentage == 0) return 'FATAL';
    if (percentage >= 95) return 'Excellent';
    if (percentage >= 85) return 'Good';
    if (percentage >= 75) return 'Average';
    if (percentage >= 60) return 'Below Average';
    return 'Poor';
  }

  Color _getQualityColor(double percentage) {
    if (percentage == 0) return Theme.of(context).colorScheme.onSurface;
    if (percentage >= 85) return Theme.of(context).colorScheme.tertiary;
    if (percentage >= 75) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.error;
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
      context.read<AddCQEntryBloc>().add(CQDateChanged(auditDate: selectedDate));
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
          content: const Text('Are you sure you want to delete this CQ entry? This action cannot be undone.'),
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
                context.read<AddCQEntryBloc>().add(const DeleteCQEntry());
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}


