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
    return const AddCQEntryView();
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
      body: BlocBuilder<AddCQEntryBloc, AddCQEntryState>(
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


