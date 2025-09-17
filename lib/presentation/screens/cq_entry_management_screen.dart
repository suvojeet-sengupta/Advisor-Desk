import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';

/// A screen for adding or editing Coaching Quality (CQ) entries.
///
/// This screen allows users to log multiple CQ audits at once. If an existing
/// [entry] is provided, it opens in edit mode for that single entry. Otherwise,
/// it prompts the user to select the number of audits they want to add.
class CqEntryManagementScreen extends StatefulWidget {
  /// An optional existing entry to be edited. If null, the screen is in "add" mode.
  final CqEntry? entry;

  /// Creates a [CqEntryManagementScreen].
  const CqEntryManagementScreen({super.key, this.entry});

  @override
  State<CqEntryManagementScreen> createState() =>
      _CqEntryManagementScreenState();
}

class _CqEntryManagementScreenState extends State<CqEntryManagementScreen> {
  int? _numberOfAudits;
  final List<_CqEntryFormData> _formEntries = [];

  @override
  void initState() {
    super.initState();
    // If editing an existing entry, initialize the form with its data.
    if (widget.entry != null) {
      _numberOfAudits = 1;
      _formEntries.add(_CqEntryFormData(entry: widget.entry));
    }
  }

  /// Updates the number of forms to be displayed.
  void _onNumberOfAuditsChanged(int? value) {
    if (value != null) {
      setState(() {
        _numberOfAudits = value;
        _formEntries.clear();
        for (int i = 0; i < _numberOfAudits!; i++) {
          _formEntries.add(_CqEntryFormData());
        }
      });
    }
  }

  /// Validates all forms and dispatches events to add the entries.
  void _addEntries() {
    final addEntryBloc = context.read<AddEntryBloc>();
    bool allFormsValid = true;
    for (final formData in _formEntries) {
      if (!formData.formKey.currentState!.validate()) {
        allFormsValid = false;
      }
    }

    if (allFormsValid) {
      for (final formData in _formEntries) {
        final entry = CqEntry(
          id: formData.entry?.id,
          auditDate: formData.selectedDate,
          cifId: formData.cifIdController.text,
          callerId: formData.callerIdController.text,
          totalScore: int.parse(formData.totalScoreController.text),
          outOf: int.parse(formData.outOfController.text),
        );
        addEntryBloc.add(AddCqEntryEvent(entry));
      }
      Navigator.of(context).pop(true); // Pop with a result to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entry != null ? 'Edit CQ Entry' : 'Add CQ Entries',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _numberOfAudits == null ? _buildAuditNumberSelector() : _buildForms(),
      ),
    );
  }

  /// Builds the dropdown to select the number of audits to log.
  Widget _buildAuditNumberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many audits do you want to log?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _numberOfAudits,
          items: List.generate(10, (index) => index + 1)
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text('$value ${value == 1 ? 'Audit' : 'Audits'}'),
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

  /// Builds the list of CQ entry forms.
  Widget _buildForms() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _numberOfAudits,
            itemBuilder: (context, index) {
              return _CqEntryForm(
                formData: _formEntries[index],
                formIndex: index + 1,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: widget.entry != null ? 'Save Changes' : 'Add Entries',
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

/// A helper class to manage the state and controllers for a single CQ entry form.
class _CqEntryFormData {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final CqEntry? entry;
  late final TextEditingController cifIdController;
  late final TextEditingController callerIdController;
  late final TextEditingController totalScoreController;
  late final TextEditingController outOfController;
  DateTime selectedDate;

  _CqEntryFormData({this.entry})
      : selectedDate = entry?.auditDate ?? DateTime.now() {
    cifIdController = TextEditingController(text: entry?.cifId);
    callerIdController = TextEditingController(text: entry?.callerId);
    totalScoreController =
        TextEditingController(text: entry?.totalScore.toString());
    outOfController = TextEditingController(text: entry?.outOf.toString());
  }

  /// Disposes all the text editing controllers.
  void dispose() {
    cifIdController.dispose();
    callerIdController.dispose();
    totalScoreController.dispose();
    outOfController.dispose();
  }
}

/// A stateful widget that represents the form for a single CQ entry.
class _CqEntryForm extends StatefulWidget {
  final _CqEntryFormData formData;
  final int formIndex;

  const _CqEntryForm({required this.formData, required this.formIndex});

  @override
  State<_CqEntryForm> createState() => __CqEntryFormState();
}

class __CqEntryFormState extends State<_CqEntryForm> {
  /// Shows a date picker to select the audit date.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.formData.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != widget.formData.selectedDate) {
      setState(() {
        widget.formData.selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formData.formKey,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Audit #${widget.formIndex}',
                  style: Theme.of(context).textTheme.titleMedium),
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
                controller: widget.formData.cifIdController,
                labelText: 'CIF ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CIF ID';
                  }
                  return null;
                },
              ),
              CustomFormField(
                controller: widget.formData.callerIdController,
                labelText: 'Caller ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Caller ID';
                  }
                  return null;
                },
              ),
              CustomFormField(
                controller: widget.formData.totalScoreController,
                labelText: 'Total Score',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Total Score';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              CustomFormField(
                controller: widget.formData.outOfController,
                labelText: 'Out Of',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Out Of score';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}