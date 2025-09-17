import 'package:advisor_desk/presentation/common/theme/share_card_themes.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A widget that displays a shareable card with a summary of monthly performance.
///
/// This widget is designed to be captured as an image and shared on social media
/// or other platforms.
class PerformanceShareCard extends StatefulWidget {
  /// The monthly summary data to display.
  final MonthlySummary summary;
  /// The user's profile information.
  final Profile profile;
  /// The theme to use for the card.
  final ShareCardTheme theme;

  /// Creates a performance share card.
  const PerformanceShareCard({
    Key? key,
    required this.summary,
    required this.profile,
    required this.theme,
  }) : super(key: key);

  @override
  _PerformanceShareCardState createState() => _PerformanceShareCardState();
}

class _PerformanceShareCardState extends State<PerformanceShareCard> {
  String _appVersion = '';

  final List<Shadow> _textShadows = const [
    Shadow(
      offset: Offset(1.0, 1.0),
      blurRadius: 3.0,
      color: Colors.black54,
    ),
  ];

  final List<Shadow> _highlightShadows = const [
    Shadow(
      offset: Offset(1.0, 1.0),
      blurRadius: 5.0,
      color: Colors.black87,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  /// Initializes the package info to get the app version.
  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${info.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.theme.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset('assets/icon/app_icon.png', width: 36, height: 36),
              const SizedBox(width: 12),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: widget.theme.textColor,
                  shadows: _textShadows,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Monthly Performance',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: widget.theme.textColor,
              shadows: _textShadows,
            ),
          ),
          Text(
            widget.summary.formattedMonthYear,
            style: TextStyle(
              fontSize: 18,
              color: widget.theme.textColor.withOpacity(0.8),
              shadows: _textShadows,
            ),
          ),
          if (widget.profile.name != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.profile.name!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: widget.theme.textColor,
                shadows: _textShadows,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildInfoRow(
            context,
            Icons.timer_outlined,
            'Total Login Hours',
            '${formatter.format(widget.summary.totalLoginHours)} hrs',
          ),
          _buildInfoRow(
            context,
            Icons.phone_in_talk_outlined,
            'Total Calls',
            widget.summary.totalCalls.toString(),
          ),
          _buildInfoRow(
            context,
            Icons.star_border_rounded,
            'CSAT Score',
            '${widget.summary.csatSummary?.monthlyCSATPercentage.toStringAsFixed(2) ?? 'N/A'}%',
          ),
          _buildInfoRow(
            context,
            Icons.check_circle_outline_rounded,
            'CQ Score',
            '${widget.summary.cqSummary?.monthlyAverageCQ.toStringAsFixed(2) ?? 'N/A'}%',
          ),
          const SizedBox(height: 12),
          Divider(color: widget.theme.textColor.withOpacity(0.2)),
          const SizedBox(height: 12),
          _buildSalaryRow(
            context,
            Icons.account_balance_wallet_outlined,
            'Net Salary',
            '₹ ${formatter.format(widget.summary.netSalary)}',
          ),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  /// Builds a row for displaying a piece of information.
  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: widget.theme.iconColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: widget.theme.textColor, shadows: _textShadows),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.theme.textColor,
              shadows: _textShadows,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the row for displaying the salary.
  Widget _buildSalaryRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 28, color: widget.theme.iconColor),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.theme.textColor,
              shadows: _textShadows,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.yellowAccent, // Highlighted color
              shadows: _highlightShadows, // Stronger shadow for highlight
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the footer of the card with the app name and QR code.
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generated by Advisor Desk',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: widget.theme.footerTextColor,
                shadows: _textShadows,
              ),
            ),
            Text(
              _appVersion,
              style: TextStyle(
                fontSize: 10,
                color: widget.theme.footerTextColor,
                shadows: _textShadows,
              ),
            ),
          ],
        ),
        QrImageView(
          data: 'https://play.google.com/store/apps/details?id=com.suvojeet.advisordesk', // Replace with your app's URL
          version: QrVersions.auto,
          size: 60.0,
          backgroundColor: Colors.white,
          gapless: false,
        ),
      ],
    );
  }
}
