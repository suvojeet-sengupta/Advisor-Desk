import 'package:advisor_desk/domain/entities/csat_summary.dart';
import 'package:advisor_desk/domain/entities/cq_summary.dart';
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/presentation/features/dashboard/bloc/goals_state.dart';

abstract class AiInsightEvent extends Equatable {
  const AiInsightEvent();

  @override
  List<Object> get props => [];
}

class GenerateInsight extends AiInsightEvent {
  final MonthlySummary summary;
  final GoalsState goals;
  final Profile profile;

  const GenerateInsight({
    required this.summary,
    required this.goals,
    required this.profile,
  });

  @override
  List<Object> get props => [summary, goals, profile];
}

class GenerateAnalyzerInsight extends AiInsightEvent {
  final MonthlySummary summary;
  final CSATSummary csatSummary;
  final CQSummary cqSummary;
  final GoalsState goals;
  final Profile profile;

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
