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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.fact_check_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.get(language, 'select_audits_today'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'How many quality audits would you like to record?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(5, (index) => index + 1).map((value) {
              final isSelected = _numberOfAudits == value;
              return InkWell(
                onTap: () => _onNumberOfAuditsChanged(value),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildForms(Language language) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 20),
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
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: _addEntries,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.entryToEdit != null ? Icons.published_with_changes_rounded : Icons.save_rounded),
                const SizedBox(width: 10),
                Text(
                  widget.entryToEdit != null ? AppStrings.get(language, 'update_entry_btn') : AppStrings.get(language, 'save_daily_entry_btn'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
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
    return CustomCard(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.get(widget.language, 'entry_label')} #${widget.formIndex}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'CQ Audit',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionLabel(context, AppStrings.get(widget.language, 'date_label')),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('dd MMMM yyyy').format(widget.formData.selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Icon(Icons.edit_rounded, size: 16, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomFormField(
            controller: widget.formData.percentageController,
            label: AppStrings.get(widget.language, 'cq_percentage_label'),
            hintText: '100.0',
            icon: Icons.percent_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {},
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.get(widget.language, 'enter_percentage_error');
              }
              final val = double.tryParse(value);
              if (val == null) {
                return AppStrings.get(widget.language, 'valid_number_error');
              }
              if (val < 0 || val > 100) {
                return '0-100%';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    );
  }
}