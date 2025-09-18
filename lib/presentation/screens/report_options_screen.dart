import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/domain/usecases/get_all_monthly_summaries_usecase.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';

class ReportOptionsScreen extends StatefulWidget {
  final GetAllMonthlySummariesUseCase getAllMonthlySummariesUseCase;

  const ReportOptionsScreen(
      {Key? key, required this.getAllMonthlySummariesUseCase})
      : super(key: key);

  @override
  State<ReportOptionsScreen> createState() => _ReportOptionsScreenState();
}

class _ReportOptionsScreenState extends State<ReportOptionsScreen> {
  List<ReportSection> _selectedSections = ReportSection.values.toList();

  List<int> _years = [];
  List<int> _months = [];
  int? _selectedYear;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchAvailableDates();
  }

  Future<void> _fetchAvailableDates() async {
    final summaries = await widget.getAllMonthlySummariesUseCase.execute();
    final Map<int, Set<int>> yearMonthMap = {};
    for (final summary in summaries) {
      if (!yearMonthMap.containsKey(summary.year)) {
        yearMonthMap[summary.year] = {};
      }
      yearMonthMap[summary.year]!.add(summary.month);
    }

    setState(() {
      _years = yearMonthMap.keys.toList()..sort((a, b) => b.compareTo(a));
      if (_years.isNotEmpty) {
        _selectedYear = _years.first;
        _months = yearMonthMap[_selectedYear]!.toList()..sort((a, b) => b.compareTo(a));
        if (_months.isNotEmpty) {
          _selectedMonth = _months.first;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Generate Custom Report'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Select Period'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildYearDropdown(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMonthDropdown(),
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
              child: AnimatedButton(
                onPressed: () {
                  if (_selectedSections.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please select at least one section.'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  if (_selectedYear != null && _selectedMonth != null) {
                    final startDate = DateTime(_selectedYear!, _selectedMonth!, 1);
                    final endDate = DateTime(_selectedYear!, _selectedMonth! + 1, 1).subtract(const Duration(microseconds: 1));
                    Navigator.pop(context, {
                      'startDate': startDate,
                      'endDate': endDate,
                      'selectedSections': _selectedSections,
                    });
                  }
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Generate Report'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedYear,
      items: _years.map((year) {
        return DropdownMenuItem<int>(
          value: year,
          child: Text(year.toString()),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedYear = newValue;
          // Update months based on selected year
          // This logic needs to be re-implemented based on how you get the months for a year
          _selectedMonth = null;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      items: _months.map((month) {
        return DropdownMenuItem<int>(
          value: month,
          child: Text(DateFormat.MMMM().format(DateTime(0, month))),
        );
      }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedMonth = newValue;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Month',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
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