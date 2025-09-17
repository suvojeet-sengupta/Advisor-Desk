import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/domain/usecases/get_all_monthly_summaries_usecase.dart';

/// A screen where users can configure options for generating a custom report.
///
/// This screen allows users to select a specific month and year, and choose
/// which sections to include in the final report. The selected options are
/// then passed back to the previous screen for report generation.
class ReportOptionsScreen extends StatefulWidget {
  /// The use case for fetching all available monthly summaries.
  final GetAllMonthlySummariesUseCase getAllMonthlySummariesUseCase;

  /// Creates a [ReportOptionsScreen].
  const ReportOptionsScreen(
      {super.key, required this.getAllMonthlySummariesUseCase});

  @override
  State<ReportOptionsScreen> createState() => _ReportOptionsScreenState();
}

class _ReportOptionsScreenState extends State<ReportOptionsScreen> {
  List<ReportSection> _selectedSections = ReportSection.values.toList();

  List<int> _years = [];
  Map<int, List<int>> _yearMonthMap = {};
  int? _selectedYear;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchAvailableDates();
  }

  /// Fetches the available years and months from the database to populate the dropdowns.
  Future<void> _fetchAvailableDates() async {
    final summaries = await widget.getAllMonthlySummariesUseCase.execute();
    final Map<int, Set<int>> yearMonthMap = {};
    for (final summary in summaries) {
      yearMonthMap.putIfAbsent(summary.year, () => {}).add(summary.month);
    }

    setState(() {
      _yearMonthMap = yearMonthMap.map((key, value) =>
          MapEntry(key, value.toList()..sort((a, b) => b.compareTo(a))));
      _years = _yearMonthMap.keys.toList()..sort((a, b) => b.compareTo(a));
      if (_years.isNotEmpty) {
        _selectedYear = _years.first;
        _updateMonthsForSelectedYear();
      }
    });
  }

  /// Updates the list of available months when a new year is selected.
  void _updateMonthsForSelectedYear() {
    if (_selectedYear != null) {
      setState(() {
        _selectedMonth = _yearMonthMap[_selectedYear]?.first;
      });
    }
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
              child: CustomButton(
                text: 'Generate Report',
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
                    final startDate =
                        DateTime(_selectedYear!, _selectedMonth!, 1);
                    final endDate =
                        DateTime(_selectedYear!, _selectedMonth! + 1, 0);
                    Navigator.pop(context, {
                      'startDate': startDate,
                      'endDate': endDate,
                      'selectedSections': _selectedSections,
                    });
                  }
                },
                icon: Icons.picture_as_pdf,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the dropdown for selecting the report year.
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
        if (newValue != null) {
          setState(() {
            _selectedYear = newValue;
            _updateMonthsForSelectedYear();
          });
        }
      },
      decoration: const InputDecoration(
        labelText: 'Year',
        border: OutlineInputBorder(),
      ),
    );
  }

  /// Builds the dropdown for selecting the report month.
  Widget _buildMonthDropdown() {
    final months = _yearMonthMap[_selectedYear] ?? [];
    return DropdownButtonFormField<int>(
      value: _selectedMonth,
      items: months.map((month) {
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

  /// Builds a title for a section.
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

  /// Returns a user-friendly title for a given [ReportSection].
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