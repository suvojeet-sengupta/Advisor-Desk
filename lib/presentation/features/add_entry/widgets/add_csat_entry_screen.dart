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

class AddCSATEntryScreen extends StatelessWidget {
  final CSATEntry? entryToEdit;

  const AddCSATEntryScreen({Key? key, this.entryToEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AddCSATEntryView();
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
    return BlocListener<AddCSATEntryBloc, AddCSATEntryState>(
      body: BlocBuilder<AddCSATEntryBloc, AddCSATEntryState>(
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



