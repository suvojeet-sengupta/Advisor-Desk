// Call Quality (CQ) Entry Entity
import 'package:equatable/equatable.dart';

/// Represents a single Call Quality (CQ) audit entry.
///
/// This class encapsulates the details of a CQ audit, including the date of the
/// audit and the percentage score. It also provides helper methods for
/// evaluating the quality rating.
class CQEntry extends Equatable {
  /// The unique identifier for the entry. Can be null if the entry is not yet saved.
  final int? id;
  /// The date of the CQ audit.
  final DateTime auditDate;
  /// The CQ percentage score, out of 100.
  final double percentage;
  
  /// Creates a new instance of [CQEntry].
  ///
  /// The [auditDate] and [percentage] are required. The [id] is optional.
  const CQEntry({
    this.id,
    required this.auditDate,
    required this.percentage,
  });
  
  /// Determines if the CQ score indicates a need for improvement (below 80%).
  bool get needsImprovement {
    return percentage < 80.0;
  }
  
  /// Returns a descriptive quality rating based on the percentage score.
  String get qualityRating {
    if (percentage >= 95) return 'Excellent';
    if (percentage >= 85) return 'Good';
    if (percentage >= 75) return 'Average';
    if (percentage >= 60) return 'Below Average';
    return 'Poor';
  }
  
  /// Creates a copy of this [CQEntry] but with the given fields replaced with new values.
  CQEntry copyWith({
    int? id,
    DateTime? auditDate,
    double? percentage,
  }) {
    return CQEntry(
      id: id ?? this.id,
      auditDate: auditDate ?? this.auditDate,
      percentage: percentage ?? this.percentage,
    );
  }
  
  /// Converts this [CQEntry] object into a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audit_date': auditDate.millisecondsSinceEpoch,
      'percentage': percentage,
    };
  }
  
  /// Creates a [CQEntry] object from a map retrieved from the database.
  factory CQEntry.fromMap(Map<String, dynamic> map) {
    return CQEntry(
      id: map['id'],
      auditDate: DateTime.fromMillisecondsSinceEpoch(map['audit_date']),
      percentage: map['percentage'].toDouble(),
    );
  }
  
  @override
  List<Object?> get props => [id, auditDate, percentage];
}
