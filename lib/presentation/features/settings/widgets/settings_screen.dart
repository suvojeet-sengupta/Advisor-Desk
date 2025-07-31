import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart'; // Import AppRouter
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionCard(
            context,
            'App Information',
            [
              _buildInfoTile('Version', AppConstants.appVersion, Icons.info_outline),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            'Salary Settings',
            [
              _buildLinkTile(
                context,
                'Customize Salary Parameters',
                AppRouter.salarySettingsRoute,
                Icons.payments,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            'Privacy & Security',
            [
              _buildLinkTile(
                context,
                'Privacy Policy',
                'https://suvojit213.github.io/Privacy_policy_Advisor_Desk/',
                Icons.privacy_tip_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dishTvOrange),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, String url, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dishTvOrange),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (!await launchUrl(uri)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $url')),
          );
        }
      },
    );
  }
}
