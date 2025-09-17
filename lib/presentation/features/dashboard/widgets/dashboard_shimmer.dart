import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a shimmer loading effect for the dashboard.
///
/// This widget is shown while the dashboard data is being fetched.
class DashboardShimmer extends StatelessWidget {
  /// Creates a dashboard shimmer.
  const DashboardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shimmerColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;

    return Shimmer.fromColors(
      baseColor: shimmerColor,
      highlightColor: shimmerColor.withOpacity(0.3),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(height: 30, width: 150),
            const SizedBox(height: 24),
            _buildShimmerBox(height: 20, width: 200),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildShimmerCard(height: 80)),
                const SizedBox(width: 16),
                Expanded(child: _buildShimmerCard(height: 80)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildShimmerCard(height: 80)),
                const SizedBox(width: 16),
                Expanded(child: _buildShimmerCard(height: 80)),
              ],
            ),
            const SizedBox(height: 24),
            _buildShimmerBox(height: 20, width: 200),
            const SizedBox(height: 12),
            _buildShimmerCard(height: 250),
          ],
        ),
      ),
    );
  }

  /// Builds a shimmering box.
  Widget _buildShimmerBox({required double height, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Builds a shimmering card.
  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
