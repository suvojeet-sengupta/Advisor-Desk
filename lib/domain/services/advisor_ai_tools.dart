import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Defines the "tools" (Gemini function declarations) that the AI assistant can
/// call to fetch the advisor's local performance data on demand, instead of
/// stuffing the entire 12-month history into every prompt.
///
/// This mirrors the idea behind MCP (Model Context Protocol): expose a set of
/// structured tools that map to local data sources, and let the model decide
/// which ones to call. Here each tool maps to an existing
/// [PerformanceRepository] method (no new data layer is introduced).
class AdvisorAiTools {
  final PerformanceRepository _performanceRepository;

  AdvisorAiTools(this._performanceRepository);

  /// Tool/function schemas advertised to Gemini. Pass this to
  /// `generateContent(..., tools: AdvisorAiTools.tools)`.
  static final List<Tool> tools = [
    Tool(functionDeclarations: [
      FunctionDeclaration(
        'list_recent_months',
        'Recent months ki list with high-level totals (calls, hours, CSAT, CQ, '
            'net salary). Use this to discover which months have data, then '
            'drill down with the other tools.',
        Schema.object(
          properties: {
            'limit': Schema.integer(
                description: 'Kitne recent months chahiye (default 12).'),
          },
        ),
      ),
      FunctionDeclaration(
        'get_monthly_summary',
        'Ek specific mahine ki poori performance + salary breakdown (calls, '
            'hours, bonus, CSAT bonus, TDS, net salary).',
        Schema.object(
          properties: {
            'month': Schema.integer(description: 'Month number 1-12.'),
            'year': Schema.integer(description: 'Full year, e.g. 2026.'),
          },
          requiredProperties: ['month', 'year'],
        ),
      ),
      FunctionDeclaration(
        'get_entries_for_month',
        'Ek mahine ke saare daily entries (har din ke calls aur login time).',
        Schema.object(
          properties: {
            'month': Schema.integer(description: 'Month number 1-12.'),
            'year': Schema.integer(description: 'Full year, e.g. 2026.'),
          },
          requiredProperties: ['month', 'year'],
        ),
      ),
      FunctionDeclaration(
        'get_daily_entry',
        'Ek specific date ka daily entry (calls + login time). Agar entry na ho '
            'to "found": false return hota hai.',
        Schema.object(
          properties: {
            'date': Schema.string(
                description: 'Date in ISO format YYYY-MM-DD, e.g. 2026-05-09.'),
          },
          requiredProperties: ['date'],
        ),
      ),
      FunctionDeclaration(
        'get_csat_summary',
        'Ek mahine ka CSAT summary + daily CSAT entries (T2/B2/N counts, '
            'percentage).',
        Schema.object(
          properties: {
            'month': Schema.integer(description: 'Month number 1-12.'),
            'year': Schema.integer(description: 'Full year, e.g. 2026.'),
          },
          requiredProperties: ['month', 'year'],
        ),
      ),
      FunctionDeclaration(
        'get_cq_summary',
        'Ek mahine ka Call Quality (CQ) summary + audit-wise scores.',
        Schema.object(
          properties: {
            'month': Schema.integer(description: 'Month number 1-12.'),
            'year': Schema.integer(description: 'Full year, e.g. 2026.'),
          },
          requiredProperties: ['month', 'year'],
        ),
      ),
    ]),
  ];

  /// Executes a tool call returned by the model and produces a JSON-friendly
  /// map that is fed back to Gemini as a [FunctionResponse]. Never throws —
  /// errors are returned as an `{"error": ...}` map so the model can recover.
  Future<Map<String, Object?>> executeTool(
      String name, Map<String, Object?> args) async {
    // ignore: avoid_print
    print('AI TOOL CALL: $name args=$args');
    try {
      switch (name) {
        case 'list_recent_months':
          final limit = _asInt(args['limit']) ?? 12;
          final summaries =
              await _performanceRepository.getAllMonthlySummaries(limit: limit);
          return {'months': summaries.map(_monthOverviewToMap).toList()};

        case 'get_monthly_summary':
          final month = _asInt(args['month']);
          final year = _asInt(args['year']);
          if (month == null || year == null) {
            return {'error': 'month aur year dono required hain.'};
          }
          final summary =
              await _performanceRepository.getMonthlySummary(month, year);
          return _summaryToMap(summary);

        case 'get_entries_for_month':
          final month = _asInt(args['month']);
          final year = _asInt(args['year']);
          if (month == null || year == null) {
            return {'error': 'month aur year dono required hain.'};
          }
          final entries =
              await _performanceRepository.getEntriesForMonth(month, year);
          return {
            'month': month,
            'year': year,
            'entries': entries.map(_dailyEntryToMap).toList(),
          };

        case 'get_daily_entry':
          final date = _asDate(args['date']);
          if (date == null) {
            return {'error': 'Valid date (YYYY-MM-DD) required hai.'};
          }
          final entry = await _performanceRepository.getEntryForDate(date);
          if (entry == null) {
            return {'found': false, 'date': _formatDate(date)};
          }
          return {'found': true, ..._dailyEntryToMap(entry)};

        case 'get_csat_summary':
          final month = _asInt(args['month']);
          final year = _asInt(args['year']);
          if (month == null || year == null) {
            return {'error': 'month aur year dono required hain.'};
          }
          final csat = await _performanceRepository.getCSATSummary(month, year);
          return _csatSummaryToMap(csat);

        case 'get_cq_summary':
          final month = _asInt(args['month']);
          final year = _asInt(args['year']);
          if (month == null || year == null) {
            return {'error': 'month aur year dono required hain.'};
          }
          final cq = await _performanceRepository.getCQSummary(month, year);
          return _cqSummaryToMap(cq);

        default:
          return {'error': 'Unknown tool: $name'};
      }
    } catch (e) {
      return {'error': 'Tool "$name" execution failed: $e'};
    }
  }

  // --- Serialization helpers (entity -> JSON-friendly map) ---

  Map<String, Object?> _monthOverviewToMap(MonthlySummary s) {
    return {
      'month': s.month,
      'year': s.year,
      'label': s.formattedMonthYear,
      'totalCalls': s.totalCalls,
      'totalLoginHours': _round(s.totalLoginHours),
      'workingDays': s.entries.length,
      'csatPercentage': s.csatSummary == null
          ? null
          : _round(s.csatSummary!.monthlyCSATPercentage),
      'cqScore':
          s.cqSummary == null ? null : _round(s.cqSummary!.monthlyAverageCQ),
      'netSalary': _round(s.netSalary),
    };
  }

  Map<String, Object?> _summaryToMap(MonthlySummary s) {
    return {
      'month': s.month,
      'year': s.year,
      'label': s.formattedMonthYear,
      'totalCalls': s.totalCalls,
      'billableCalls': s.billableCalls,
      'nonBillableCalls': s.totalNonBillableCalls,
      'totalLoginHours': _round(s.totalLoginHours),
      'workingDays': s.entries.length,
      'avgCallsPerDay': _round(s.averageDailyCalls),
      'avgHoursPerDay': _round(s.averageDailyLoginHours),
      'csatPercentage': s.csatSummary == null
          ? null
          : _round(s.csatSummary!.monthlyCSATPercentage),
      'cqScore':
          s.cqSummary == null ? null : _round(s.cqSummary!.monthlyAverageCQ),
      'salary': {
        'baseSalary': _round(s.baseSalary),
        'performanceBonus': _round(s.bonusAmount),
        'bonusAchieved': s.isBonusAchieved,
        'csatBonus': _round(s.csatBonus),
        'grossSalary': _round(s.totalSalary + s.csatBonus),
        'tdsDeduction': _round(s.tdsDeduction),
        'netSalary': _round(s.netSalary),
      },
    };
  }

  Map<String, Object?> _dailyEntryToMap(DailyEntry e) {
    return {
      'date': _formatDate(e.date),
      'calls': e.callCount,
      'loginTime': e.formattedLoginTime,
      'loginHours': _round(e.totalLoginTimeInHours),
      'customCallRate': e.customCallRate,
    };
  }

  Map<String, Object?> _csatSummaryToMap(CSATSummary c) {
    return {
      'month': c.month,
      'year': c.year,
      'csatPercentage': _round(c.monthlyCSATPercentage),
      'totalT2': c.totalT2Count,
      'totalB2': c.totalB2Count,
      'totalN': c.totalNCount,
      'totalSurveyHits': c.totalSurveyHits,
      'entries': c.entries
          .map((e) => {
                'date': _formatDate(e.date),
                't2': e.t2Count,
                'b2': e.b2Count,
                'n': e.nCount,
                'csatPercentage': _round(e.csatPercentage),
              })
          .toList(),
    };
  }

  Map<String, Object?> _cqSummaryToMap(CQSummary c) {
    return {
      'month': c.month,
      'year': c.year,
      'averageCQ': _round(c.monthlyAverageCQ),
      'rating': c.qualityRating,
      'totalAudits': c.totalAudits,
      'entries': c.entries
          .map((e) => {
                'date': _formatDate(e.auditDate),
                'score': _round(e.percentage),
              })
          .toList(),
    };
  }

  // --- Arg coercion + formatting ---

  int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  DateTime? _asDate(Object? v) {
    if (v is! String) return null;
    return DateTime.tryParse(v.trim());
  }

  String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  double _round(double v) => double.parse(v.toStringAsFixed(2));
}
