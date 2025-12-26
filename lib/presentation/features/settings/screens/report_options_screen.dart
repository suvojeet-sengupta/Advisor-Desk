import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Generate Custom Report'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            _buildSectionHeader(context, 'Select Period'),
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(child: _buildYearDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMonthDropdown()),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Report Sections'),
            CustomCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: ReportSection.values.asMap().entries.map((entry) {
                   final index = entry.key;
                   final section = entry.value;
                   final isLast = index == ReportSection.values.length - 1;
                   
                   return Column(
                     children: [
                       CheckboxListTile(
                         activeColor: Theme.of(context).colorScheme.primary,
                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                         title: Text(
                           _getSectionTitleText(section),
                           style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                         ),
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
                       ),
                       if (!isLast)
                         Divider(height: 1, indent: 16, endIndent: 16, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                     ],
                   );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 40),
            
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
                    Icon(Icons.picture_as_pdf_rounded),
                    SizedBox(width: 8),
                    Text('Generate Report'),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          isExpanded: true,
          hint: const Text('Year'),
          items: _years.map((year) {
            return DropdownMenuItem<int>(
              value: year,
              child: Text(year.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _selectedYear = newValue;
              _selectedMonth = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
         color: Theme.of(context).scaffoldBackgroundColor,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
           value: _selectedMonth,
           isExpanded: true,
           hint: const Text('Month'),
           items: _months.map((month) {
            return DropdownMenuItem<int>(
              value: month,
              child: Text(DateFormat.MMMM().format(DateTime(0, month)), style: const TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _selectedMonth = newValue;
            });
          },
        ),
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
