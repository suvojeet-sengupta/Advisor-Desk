import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:equatable/equatable.dart';

/// The status of the "All Reports" feature.
enum AllReportsStatus { initial, loading, loaded, error }

/// The state for the "All Reports" feature.
///
/// This class holds all the data related to the state of the feature,
/// including the current status, a list of monthly summaries, and any error messages.
class AllReportsState extends Equatable {
  /// The current status of the operation.
  final AllReportsStatus status;
  /// The list of monthly summaries.
  final List<MonthlySummary> summaries;
  /// An error message, if any.
  final String? errorMessage;

  /// Creates a new instance of [AllReportsState].
  const AllReportsState({
    this.status = AllReportsStatus.initial,
    this.summaries = const [],
    this.errorMessage,
  });

  /// Creates a copy of this state but with the given fields replaced with new values.
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