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
import 'package:advisor_desk/data/datasources/ad_service.dart';

/// A screen for adding or editing a Call Quality (CQ) entry.
///
/// This screen provides a form for the user to input CQ data. It uses the
/// [AddCQEntryBloc] to manage the state of the form.
class AddCQEntryScreen extends StatelessWidget {
  /// The entry to be edited. If null, a new entry is created.
  final CQEntry? entryToEdit;

  /// Creates an [AddCQEntryScreen].
  const AddCQEntryScreen({super.key, this.entryToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddCQEntryBloc(
        repository: context.read<PerformanceRepository>(),
        adService: context.read<AdService>(),
      )..add(InitializeCQEntry(entry: entryToEdit)),
      child: AddCQEntryView(entryToEdit: entryToEdit),
    );
  }
}

/// The view for the [AddCQEntryScreen].
class AddCQEntryView extends StatefulWidget {
  /// The entry to be edited.
  final CQEntry? entryToEdit;
  /// Creates an [AddCQEntryView].
  const AddCQEntryView({super.key, this.entryToEdit});

  @override
  State<AddCQEntryView> createState() => _AddCQEntryViewState();
}

class _AddCQEntryViewState extends State<AddCQEntryView> {
  int? _numberOfAudits;
  final List<_CQEntryFormData> _formEntries = [];

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      _numberOfAudits = 1;
      _formEntries.add(_CQEntryFormData(entry: widget.entryToEdit));
    }
  }

  void _onNumberOfAuditsChanged(int? value) {
    if (value != null) {
      setState(() {
        _numberOfAudits = value;
        _formEntries.clear();
        for (int i = 0; i < _numberOfAudits!; i++) {
          _formEntries.add(_CQEntryFormData());
        }
      });
    }
  }

  void _addEntries() {
    final bloc = context.read<AddCQEntryBloc>();
    for (final formData in _formEntries) {
        final entry = CQEntry(
          id: formData.entry?.id,
          auditDate: formData.selectedDate,
          percentage: double.tryParse(formData.percentageController.text) ?? 0.0,
        );
        bloc.add(SubmitCQEntry(entry: entry, isUpdate: formData.entry != null));
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entryToEdit != null ? 'Edit CQ Entry' : 'Add CQ Entries',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _numberOfAudits == null
            ? _buildAuditNumberSelector()
            : _buildForms(),
      ),
    );
  }

  Widget _buildAuditNumberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the number of audits Today',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _numberOfAudits,
          items: List.generate(5, (index) => index + 1)
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.toString()),
                  ))
              .toList(),
          onChanged: _onNumberOfAuditsChanged,
          decoration: const InputDecoration(
            labelText: 'Number of Audits',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildForms() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _numberOfAudits,
            itemBuilder: (context, index) {
              return _CQEntryForm(
                formData: _formEntries[index],
                formIndex: index + 1,
              );
            },
          ),
        ),
        CustomButton(
          text: 'Add Entries',
          onPressed: _addEntries,
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final formData in _formEntries) {
      formData.dispose();
    }
    super.dispose();
  }
}

/// A helper class to hold the form data for a single CQ entry.
class _CQEntryFormData {
  /// The existing entry, if any.
  final CQEntry? entry;
  /// The controller for the percentage text field.
  late final TextEditingController percentageController;
  /// The selected date for the entry.
  DateTime selectedDate;

  /// Creates a [_CQEntryFormData].
  _CQEntryFormData({this.entry}) : selectedDate = entry?.auditDate ?? DateTime.now() {
    percentageController = TextEditingController(text: entry?.percentage.toString());
  }

  /// Disposes the controller.
  void dispose() {
    percentageController.dispose();
  }
}

/// A form for a single CQ entry.
class _CQEntryForm extends StatefulWidget {
  /// The form data for this form.
  final _CQEntryFormData formData;
  /// The index of this form in the list.
  final int formIndex;

  /// Creates a [_CQEntryForm].
  const _CQEntryForm({required this.formData, required this.formIndex});

  @override
  __CQEntryFormState createState() => __CQEntryFormState();
}

class __CQEntryFormState extends State<_CQEntryForm> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.formData.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.formData.selectedDate) {
      setState(() {
        widget.formData.selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entry ${widget.formIndex}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date: ${DateFormat.yMd().format(widget.formData.selectedDate)}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            CustomFormField(
              controller: widget.formData.percentageController,
              label: 'CQ Percentage',
              hintText: 'Enter CQ percentage (0-100)',
              icon: Icons.assessment,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter percentage';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}