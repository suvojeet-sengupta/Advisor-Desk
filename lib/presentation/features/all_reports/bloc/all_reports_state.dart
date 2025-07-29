import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:equatable/equatable.dart';

enum AllReportsStatus { initial, loading, loaded, error }

class AllReportsState extends Equatable {
  final AllReportsStatus status;
  final List<MonthlySummary> summaries;
  final String? errorMessage;

  const AllReportsState({
    this.status = AllReportsStatus.initial,
    this.summaries = const [],
    this.errorMessage,
  });

  AllReportsState copyWith({
    AllReportsStatus? status,
    List<MonthlySummary>? summaries,
    String? errorMessage,
  }) {
    return AllReportsState(
      status: status ?? this.status,
      summaries: summaries ?? this.summaries,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summaries, errorMessage];
}