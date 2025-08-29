import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';

class CqEntryManagementScreen extends StatefulWidget {
  final CqEntry? entry;

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
    if (widget.entry != null) {
      _numberOfAudits = 1;
      _formEntries.add(_CqEntryFormData(entry: widget.entry));
    }
  }

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

  void _addEntries() {
    final addEntryBloc = context.read<AddEntryBloc>();
    for (final formData in _formEntries) {
      if (formData.formKey.currentState!.validate()) {
        final entry = CqEntry(
          id: formData.entry?.id,
          date: formData.selectedDate,
          cifId: formData.cifIdController.text,
          callerId: formData.callerIdController.text,
          totalScore: int.parse(formData.totalScoreController.text),
          outOf: int.parse(formData.outOfController.text),
        );
        addEntryBloc.add(AddCqEntryEvent(entry));
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entry != null ? 'Edit CQ Entry' : 'Add CQ Entries',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _numberOfAudits == null ? _buildAuditNumberSelector() : _buildForms(),
      ),
    );
  }

  Widget _buildAuditNumberSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many audits did you do today?',
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
              return _CqEntryForm(
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

class _CqEntryFormData {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final CqEntry? entry;
  late final TextEditingController cifIdController;
  late final TextEditingController callerIdController;
  late final TextEditingController totalScoreController;
  late final TextEditingController outOfController;
  DateTime selectedDate;

  _CqEntryFormData({this.entry}) : selectedDate = entry?.date ?? DateTime.now() {
    cifIdController = TextEditingController(text: entry?.cifId);
    callerIdController = TextEditingController(text: entry?.callerId);
    totalScoreController = TextEditingController(text: entry?.totalScore.toString());
    outOfController = TextEditingController(text: entry?.outOf.toString());
  }

  void dispose() {
    cifIdController.dispose();
    callerIdController.dispose();
    totalScoreController.dispose();
    outOfController.dispose();
  }
}

class _CqEntryForm extends StatefulWidget {
  final _CqEntryFormData formData;
  final int formIndex;

  const _CqEntryForm({required this.formData, required this.formIndex});

  @override
  __CqEntryFormState createState() => __CqEntryFormState();
}

class __CqEntryFormState extends State<_CqEntryForm> {
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
    return Form(
      key: widget.formData.formKey,
      child: Card(
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