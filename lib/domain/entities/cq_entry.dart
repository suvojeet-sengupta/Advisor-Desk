// Call Quality (CQ) Entry Entity
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/utils/quality_rating_helper.dart';

class CQEntry extends Equatable {
  final int? id;
  final DateTime auditDate;
  final double percentage; // CQ percentage out of 100
  
  const CQEntry({
    this.id,
    required this.auditDate,
    required this.percentage,
  });
  
  // Check if CQ needs improvement (below 80%)
  bool get needsImprovement {
    return percentage < 80.0;
  }
  
  // Get quality rating based on percentage
  String get qualityRating {
    return QualityRatingHelper.getQualityRating(percentage);
  }
  
  // Copy with method for creating a new instance with some updated values
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
  
  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audit_date': auditDate.millisecondsSinceEpoch,
      'percentage': percentage,
    };
  }
  
  // Create from Map for database operations
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

