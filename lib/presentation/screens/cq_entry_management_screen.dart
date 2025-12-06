import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_entry_event.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

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
    bool allValid = true;
    for (final formData in _formEntries) {
      if (!formData.formKey.currentState!.validate()) {
        allValid = false;
      }
    }

    if (allValid) {
      for (final formData in _formEntries) {
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.entry != null ? 'Edit CQ Entry' : 'Add CQ Entries',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _numberOfAudits == null ? _buildAuditNumberSelector() : _buildForms(),
        ),
      ),
    );
  }

  Widget _buildAuditNumberSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.fact_check_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Start Audit Session',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'How many audits did you complete today?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(5, (index) {
              final val = index + 1;
              return GestureDetector(
                onTap: () => _onNumberOfAuditsChanged(val),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$val',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildForms() {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _numberOfAudits ?? 0,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              return _CqEntryForm(
                formData: _formEntries[index],
                formIndex: index + 1,
              );
            },
          ),
        ),
        CustomButton(
          text: widget.entry != null ? 'Update Entry' : 'Add Entries',
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
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry #${widget.formIndex}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(widget.formData.selectedDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomFormField(
                    controller: widget.formData.cifIdController,
                    labelText: 'CIF ID',
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomFormField(
                    controller: widget.formData.callerIdController,
                    labelText: 'Caller ID',
                    prefixIcon: Icons.phone_callback_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
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
                    controller: widget.formData.totalScoreController,
                    labelText: 'Score',
                    prefixIcon: Icons.score_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (int.tryParse(value) == null) return 'Invalid';
                      if (widget.formData.outOfController.text.isNotEmpty) {
                         final outOf = int.tryParse(widget.formData.outOfController.text);
                         final score = int.tryParse(value);
                         if (outOf != null && score != null && score > outOf) {
                           return 'Score > Max';
                         }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomFormField(
                    controller: widget.formData.outOfController,
                    labelText: 'Out Of',
                    prefixIcon: Icons.rule_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (int.tryParse(value) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
