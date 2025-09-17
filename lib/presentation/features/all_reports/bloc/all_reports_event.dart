import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:equatable/equatable.dart';

/// The base class for all events related to the "All Reports" feature.
abstract class AllReportsEvent extends Equatable {
  const AllReportsEvent();

  @override
  List<Object> get props => [];
}

/// An event to load all monthly summaries.
class LoadAllMonthlySummaries extends AllReportsEvent {}

/// An event to export a monthly report as a PDF.
class ExportMonthlyReportAsPdf extends AllReportsEvent {
  /// The summary to be exported.
  final MonthlySummary summary;

  /// Creates an [ExportMonthlyReportAsPdf] event.
  const ExportMonthlyReportAsPdf(this.summary);

  @override
  List<Object> get props => [summary];
}