// Call Quality (CQ) Entry Entity
import 'package:equatable/equatable.dart';
import 'package:advisor_desk/core/utils/quality_rating_helper.dart';

class CQEntry extends Equatable {
  final int? id;
  final DateTime auditDate;
  final double percentage; // CQ percentage out of 100
  final String? cifId;
  final String? callerId;
  final int? totalScore;
  final int? outOf;

  const CQEntry({
    this.id,
    required this.auditDate,
    required this.percentage,
    this.cifId,
    this.callerId,
    this.totalScore,
    this.outOf,
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
    String? cifId,
    String? callerId,
    int? totalScore,
    int? outOf,
  }) {
    return CQEntry(
      id: id ?? this.id,
      auditDate: auditDate ?? this.auditDate,
      percentage: percentage ?? this.percentage,
      cifId: cifId ?? this.cifId,
      callerId: callerId ?? this.callerId,
      totalScore: totalScore ?? this.totalScore,
      outOf: outOf ?? this.outOf,
    );
  }
  
  // Convert to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audit_date': auditDate.millisecondsSinceEpoch,
      'percentage': percentage,
      'cif_id': cifId,
      'caller_id': callerId,
      'total_score': totalScore,
      'out_of': outOf,
    };
  }
  
  // Create from Map for database operations
  factory CQEntry.fromMap(Map<String, dynamic> map) {
    return CQEntry(
      id: map['id'],
      auditDate: DateTime.fromMillisecondsSinceEpoch(map['audit_date']),
      percentage: map['percentage'].toDouble(),
      cifId: map['cif_id'],
      callerId: map['caller_id'],
      totalScore: map['total_score'],
      outOf: map['out_of'],
    );
  }
  
  @override
  List<Object?> get props => [id, auditDate, percentage, cifId, callerId, totalScore, outOf];
}

