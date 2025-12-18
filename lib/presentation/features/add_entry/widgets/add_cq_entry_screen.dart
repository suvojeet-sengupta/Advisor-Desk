import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_bloc.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_event.dart';
import 'package:advisor_desk/presentation/features/add_entry/bloc/add_cq_entry_state.dart';
import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

class AddCQEntryScreen extends StatelessWidget {
  final CQEntry? entryToEdit;

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

class AddCQEntryView extends StatefulWidget {
  final CQEntry? entryToEdit;
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
    return BlocBuilder<LanguageCubit, Language>(
      builder: (context, language) {
        return Scaffold(
          appBar: CustomAppBar(
            title: widget.entryToEdit != null ? AppStrings.get(language, 'update_cq_entry') : AppStrings.get(language, 'add_cq_entries'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _numberOfAudits == null
                ? _buildAuditNumberSelector(language)
                : _buildForms(language),
          ),
        );
      },
    );
  }

  Widget _buildAuditNumberSelector(Language language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.get(language, 'select_audits_today'),
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
          decoration: InputDecoration(
            labelText: AppStrings.get(language, 'number_of_audits_label'),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildForms(Language language) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _numberOfAudits,
            itemBuilder: (context, index) {
              return _CQEntryForm(
                formData: _formEntries[index],
                formIndex: index + 1,
                language: language,
              );
            },
          ),
        ),
        AnimatedButton(
          onPressed: _addEntries,
          child: Text(AppStrings.get(language, 'add_entries_btn')),
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

class _CQEntryFormData {
  final CQEntry? entry;
  late final TextEditingController percentageController;
  DateTime selectedDate;

  _CQEntryFormData({this.entry}) : selectedDate = entry?.auditDate ?? DateTime.now() {
    percentageController = TextEditingController(text: entry?.percentage.toString());
  }

  void dispose() {
    percentageController.dispose();
  }
}

class _CQEntryForm extends StatefulWidget {
  final _CQEntryFormData formData;
  final int formIndex;
  final Language language;

  const _CQEntryForm({
    required this.formData, 
    required this.formIndex,
    required this.language,
  });

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
            Text('${AppStrings.get(widget.language, 'entry_label')} ${widget.formIndex}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppStrings.get(widget.language, 'date_label')}: ${DateFormat.yMd().format(widget.formData.selectedDate)}',
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
              label: AppStrings.get(widget.language, 'cq_percentage_label'),
              hintText: AppStrings.get(widget.language, 'cq_percentage_hint'),
              icon: Icons.assessment,
              keyboardType: TextInputType.number,
              onChanged: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.get(widget.language, 'enter_percentage_error');
                }
                if (double.tryParse(value) == null) {
                  return AppStrings.get(widget.language, 'valid_number_error');
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