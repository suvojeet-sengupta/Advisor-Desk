// CSAT Entry Entity
import 'package:equatable/equatable.dart';

/// Represents a single Customer Satisfaction (CSAT) entry for a specific day.
///
/// This class encapsulates the counts of different survey responses (T2, B2, N)
/// and provides calculated properties for CSAT scores and percentages.
class CSATEntry extends Equatable {
  /// The unique identifier for the entry. Can be null if the entry is not yet saved.
  final int? id;
  /// The date of the CSAT entry.
  final DateTime date;
  /// The count of "Top 2" (positive) survey responses.
  final int t2Count;
  /// The count of "Bottom 2" (negative) survey responses.
  final int b2Count;
  /// The count of "Neutral" survey responses.
  final int nCount;
  
  /// Creates a new instance of [CSATEntry].
  ///
  /// The [date], [t2Count], [b2Count], and [nCount] are required. The [id] is optional.
  const CSATEntry({
    this.id,
    required this.date,
    required this.t2Count,
    required this.b2Count,
    required this.nCount,
  });
  
  /// The total number of survey responses.
  int get totalSurveyHits {
    return t2Count + b2Count + nCount;
  }
  
  /// The percentage score for neutral responses.
  double get nScore {
    if (totalSurveyHits == 0) return 0.0;
    return (100 / totalSurveyHits) * nCount;
  }
  
  /// The percentage score for negative (Bottom 2) responses.
  double get b2Score {
    if (totalSurveyHits == 0) return 0.0;
    return (100 / totalSurveyHits) * b2Count;
  }
  
  /// The percentage score for positive (Top 2) responses.
  double get t2Score {
    if (totalSurveyHits == 0) return 0.0;
    return (100 / totalSurveyHits) * t2Count;
  }
  
  /// The overall CSAT percentage, calculated as (T2% - B2%).
  double get csatPercentage {
    if (totalSurveyHits == 0) return 0.0;
    return (t2Count - b2Count) / totalSurveyHits * 100;
  }
  
  /// Determines if the CSAT score indicates a need for improvement (below 60%).
  bool get needsImprovement {
    return csatPercentage < 60.0;
  }
  
  /// Creates a copy of this [CSATEntry] but with the given fields replaced with new values.
  CSATEntry copyWith({
    int? id,
    DateTime? date,
    int? t2Count,
    int? b2Count,
    int? nCount,
  }) {
    return CSATEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      t2Count: t2Count ?? this.t2Count,
      b2Count: b2Count ?? this.b2Count,
      nCount: nCount ?? this.nCount,
    );
  }
  
  /// Converts this [CSATEntry] object into a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      't2_count': t2Count,
      'b2_count': b2Count,
      'n_count': nCount,
    };
  }
  
  /// Creates a [CSATEntry] object from a map retrieved from the database.
  factory CSATEntry.fromMap(Map<String, dynamic> map) {
    return CSATEntry(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      t2Count: map['t2_count'],
      b2Count: map['b2_count'],
      nCount: map['n_count'],
    );
  }
  
  @override
  List<Object?> get props => [id, date, t2Count, b2Count, nCount];
}
