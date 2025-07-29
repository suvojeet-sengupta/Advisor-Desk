import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart'; // Import PerformanceRepository
// This comment is added to force a re-compilation.

class AddCSATEntryScreen extends StatefulWidget {
  final CSATEntry? entryToEdit;

  const AddCSATEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  State<AddCSATEntryScreen> createState() => _AddCSATEntryScreenState();
}

class _AddCSATEntryScreenState extends State<AddCSATEntryScreen> {
  late DateTime _selectedDate;
  late final TextEditingController _t2CountController;
  late final TextEditingController _b2CountController;
  late final TextEditingController _nCountController;
  int _t2Count = 0;
  int _b2Count = 0;
  int _nCount = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _t2CountController = TextEditingController();
    _b2CountController = TextEditingController();
    _nCountController = TextEditingController();

    if (widget.entryToEdit != null) {
      _selectedDate = widget.entryToEdit!.date;
      _t2CountController.text = widget.entryToEdit!.t2Count.toString();
      _b2CountController.text = widget.entryToEdit!.b2Count.toString();
      _nCountController.text = widget.entryToEdit!.nCount.toString();
    } else {
      _selectedDate = DateTime.now();
      _t2CountController.text = '';
      _b2CountController.text = '';
      _nCountController.text = '';
    }

    _t2Count = int.tryParse(_t2CountController.text) ?? 0;
    _b2Count = int.tryParse(_b2CountController.text) ?? 0;
    _nCount = int.tryParse(_nCountController.text) ?? 0;

    _t2CountController.addListener(() {
      setState(() {
        _t2Count = int.tryParse(_t2CountController.text) ?? 0;
      });
    });
    _b2CountController.addListener(() {
      setState(() {
        _b2Count = int.tryParse(_b2CountController.text) ?? 0;
      });
    });
    _nCountController.addListener(() {
      setState(() {
        _nCount = int.tryParse(_nCountController.text) ?? 0;
      });
    });
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
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entryToEdit != null ? 'Edit CSAT Entry' : 'Add CSAT Entry',
      ),
      body: SingleChildScrollView(
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

            // T2 Count Section
            CustomFormField(
              label: 'T2 Count (Positive Feedback)',
              hintText: 'Enter T2 count',
              icon: Icons.thumb_up,
              controller: _t2CountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),

            // B2 Count Section
            CustomFormField(
              label: 'B2 Count (Negative Feedback)',
              hintText: 'Enter B2 count',
              icon: Icons.thumb_down,
              controller: _b2CountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),

            // N Count Section
            CustomFormField(
              label: 'N Count (Neutral Feedback)',
              hintText: 'Enter N count',
              icon: Icons.remove,
              controller: _nCountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),

            // Preview Section
            if (_t2Count > 0 || _b2Count > 0 || _nCount > 0) ...[
              _buildSectionTitle(context, 'Preview'),
              const SizedBox(height: 8),
              CustomCard(
                child: Column(
                  children: [
                    _buildPreviewRow('Total Survey Hits', '${_t2Count + _b2Count + _nCount}'),
                    const Divider(),
                    _buildPreviewRow('T2 Score', '${_calculateScore(_t2Count).toStringAsFixed(2)}%'),
                    _buildPreviewRow('B2 Score', '${_calculateScore(_b2Count).toStringAsFixed(2)}%'),
                    _buildPreviewRow('N Score', '${_calculateScore(_nCount).toStringAsFixed(2)}%'),
                    const Divider(),
                    _buildPreviewRow(
                      'CSAT Percentage',
                      '${_calculateCSAT().toStringAsFixed(2)}%',
                      isHighlight: true,
                      color: _calculateCSAT() >= 60 ? Colors.green : Theme.of(context).colorScheme.error,
                    ),
                    if (_calculateCSAT() < 60)
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
                text: widget.entryToEdit != null ? 'Update CSAT Entry' : 'Add CSAT Entry',
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

  double _calculateScore(int count) {
    final total = _t2Count + _b2Count + _nCount;
    if (total == 0) return 0.0;
    return (100 / total) * count;
  }

  double _calculateCSAT() {
    return _calculateScore(_t2Count) - _calculateScore(_b2Count);
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
    setState(() {
      _isLoading = true;
    });

    try {
      final entry = CSATEntry(
        id: widget.entryToEdit?.id,
        date: _selectedDate,
        t2Count: int.tryParse(_t2CountController.text) ?? 0,
        b2Count: int.tryParse(_b2CountController.text) ?? 0,
        nCount: int.tryParse(_nCountController.text) ?? 0,
      );

      await context.read<PerformanceRepository>().saveCSATEntry(entry); // Use the repository

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.entryToEdit != null
                  ? 'CSAT entry updated successfully!'
                  : 'CSAT entry added successfully!',
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
            content: Text('Failed to save CSAT entry: $e'),
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
        await context.read<PerformanceRepository>().deleteCSATEntry(widget.entryToEdit!.id!); // Use the repository
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSAT entry deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Signal success to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save CSAT entry: $e'),
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


