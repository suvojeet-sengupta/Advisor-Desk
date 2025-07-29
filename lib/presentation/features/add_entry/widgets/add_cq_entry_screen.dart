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

class AddCQEntryScreen extends StatefulWidget {
  final CQEntry? entryToEdit;

  const AddCQEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  State<AddCQEntryScreen> createState() => _AddCQEntryScreenState();
}

class _AddCQEntryScreenState extends State<AddCQEntryScreen> {
  late DateTime _selectedDate;
  late double _percentage;
  bool _isLoading = false;
  final TextEditingController _percentageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      _selectedDate = widget.entryToEdit!.auditDate;
      _percentage = widget.entryToEdit!.percentage;
      _percentageController.text = _percentage.toString();
    } else {
      _selectedDate = DateTime.now();
      _percentage = 0.0;
      _percentageController.text = '';
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entryToEdit != null ? 'Edit CQ Entry' : 'Add CQ Entry',
      ),
      body: SingleChildScrollView(
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
                onTap: () => _selectDate(context),
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
                        color: AppColors.dishTvOrange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
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
                setState(() {
                  _percentage = double.tryParse(value) ?? 0.0;
                  // Ensure percentage is between 0 and 100
                  if (_percentage < 0) _percentage = 0.0;
                  if (_percentage > 100) _percentage = 100.0;
                });
              },
            ),
            const SizedBox(height: 24),

            // Preview Section
            if (_percentage > 0) ...[
              _buildSectionTitle(context, 'Preview'),
              const SizedBox(height: 8),
              CustomCard(
                child: Column(
                  children: [
                    _buildPreviewRow('CQ Percentage', '${_percentage.toStringAsFixed(2)}%'),
                    const Divider(),
                    _buildPreviewRow(
                      'Quality Rating',
                      _getQualityRating(_percentage),
                      isHighlight: true,
                      color: _getQualityColor(_percentage),
                    ),
                    if (_percentage < 80)
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
                text: widget.entryToEdit != null ? 'Update CQ Entry' : 'Add CQ Entry',
                onPressed: _isLoading ? null : _submitEntry,
                icon: widget.entryToEdit != null ? Icons.update : Icons.add,
              ),
            ),

            if (widget.entryToEdit != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Delete Entry',
                  onPressed: _isLoading ? null : () => _showDeleteConfirmationDialog(context),
                  isPrimary: false,
                  icon: Icons.delete_outline,
                ),
              ),
            ],
          ],
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
              color: color ?? (isHighlight ? AppColors.dishTvOrange : null),
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
    if (percentage == 0) return Colors.black;
    if (percentage >= 85) return Colors.green;
    if (percentage >= 75) return AppColors.dishTvOrange;
    return Colors.red;
  }

  Future<void> _selectDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.dishTvOrange,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  void _submitEntry() async {
    if (_percentage < 0 || _percentage > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid percentage between 0 and 100'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final entry = CQEntry(
        id: widget.entryToEdit?.id,
        auditDate: _selectedDate,
        percentage: _percentage,
      );

      await context.read<PerformanceRepository>().saveCQEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.entryToEdit != null
                  ? 'CQ entry updated successfully!'
                  : 'CQ entry added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Signal success to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save CQ entry: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                Navigator.of(dialogContext).pop();
                _deleteEntry();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.entryToEdit?.id != null) {
        await context.read<PerformanceRepository>().deleteCQEntry(widget.entryToEdit!.id!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CQ entry deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Signal success to previous screen
      } 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete CQ entry: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

