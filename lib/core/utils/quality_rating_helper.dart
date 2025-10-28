class QualityRatingHelper {
  static String getQualityRating(double percentage) {
    if (percentage >= 95) return 'Excellent';
    if (percentage >= 85) return 'Good';
    if (percentage >= 75) return 'Average';
    if (percentage >= 60) return 'Below Average';
    return 'Poor';
  }
}
