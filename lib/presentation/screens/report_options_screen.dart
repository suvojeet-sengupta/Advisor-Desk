import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

class ReportOptionsScreen extends StatefulWidget {
  const ReportOptionsScreen({Key? key}) : super(key: key);

  @override
  State<ReportOptionsScreen> createState() => _ReportOptionsScreenState();
}

class _ReportOptionsScreenState extends State<ReportOptionsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<ReportSection> _selectedSections = ReportSection.values.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Generate Custom Report'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Select Date Range'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateSelectionField(
                    context,
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateSelectionField(
                    context,
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Select Report Sections'),
            const SizedBox(height: 8),
            ...ReportSection.values.map((section) {
              return CheckboxListTile(
                title: Text(_getSectionTitleText(section)),
                value: _selectedSections.contains(section),
                onChanged: (bool? newValue) {
                  setState(() {
                    if (newValue == true) {
                      _selectedSections.add(section);
                    } else {
                      _selectedSections.remove(section);
                    }
                  });
                },
              );
            }).toList(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Generate Report',
                onPressed: () {
                  if (_selectedSections.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one section.'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  Navigator.pop(context, {
                    'startDate': _startDate,
                    'endDate': _endDate,
                    'selectedSections': _selectedSections,
                  });
                },
                icon: Icons.picture_as_pdf,
              ),
            ),
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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDateSelectionField(
    BuildContext context,
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
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
            if (picked != null && picked != selectedDate) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy').format(selectedDate)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getSectionTitleText(ReportSection section) {
    switch (section) {
      case ReportSection.monthlySummary:
        return 'Summary';
      case ReportSection.dailyEntries:
        return 'Daily Entries';
      case ReportSection.csatSummary:
        return 'Overall CSAT Performance';
      case ReportSection.csatDailyBreakdown:
        return 'CSAT Daily Breakdown';
      case ReportSection.cqSummary:
        return 'Overall CQ Performance';
      case ReportSection.cqDailyBreakdown:
        return 'CQ Daily Breakdown';
      case ReportSection.salaryDetails:
        return 'Salary Details';
    }
  }
}
