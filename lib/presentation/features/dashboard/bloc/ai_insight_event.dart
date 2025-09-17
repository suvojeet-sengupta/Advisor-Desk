import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';

/// The base class for all events related to the AI insight feature.
abstract class AiInsightEvent extends Equatable {
  const AiInsightEvent();

  @override
  List<Object> get props => [];
}

/// An event to generate a dashboard insight.
class GenerateInsight extends AiInsightEvent {
  /// The monthly summary data.
  final MonthlySummary summary;
  /// The user's goals.
  final GoalsState goals;
  /// The user's profile.
  final Profile profile;

  /// Creates a [GenerateInsight] event.
  const GenerateInsight({
    required this.summary,
    required this.goals,
    required this.profile,
  });

  @override
  List<Object> get props => [summary, goals, profile];
}

/// An event to generate a more detailed analyzer insight.
class GenerateAnalyzerInsight extends AiInsightEvent {
  /// The monthly summary data.
  final MonthlySummary summary;
  /// The CSAT summary data.
  final CSATSummary csatSummary;
  /// The CQ summary data.
  final CQSummary cqSummary;
  /// The user's goals.
  final GoalsState goals;
  /// The user's profile.
  final Profile profile;

  /// Creates a [GenerateAnalyzerInsight] event.
  const GenerateAnalyzerInsight({
    required this.summary,
    required this.csatSummary,
    required this.cqSummary,
    required this.goals,
    required this.profile,
  });

  @override
  List<Object> get props => [summary, csatSummary, cqSummary, goals, profile];
}
