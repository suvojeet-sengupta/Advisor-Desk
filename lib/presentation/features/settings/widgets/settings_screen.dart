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
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            'Support Development',
            [
              ListTile(
                leading: Icon(Icons.volunteer_activism, color: AppColors.dishTvOrange),
                title: const Text('Support Us'),
                subtitle: const Text('Your small contribution fuels continuous improvements and new features, helping us keep this app free and valuable for everyone.'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you for considering supporting us! Your generosity directly enables us to enhance the app. Even a small contribution, like 50rs or 100rs, makes a significant difference. You can contribute securely via UPI to suvojeetsengupta2@axl.'),
                      duration: Duration(seconds: 10), // Increased duration for better readability
                    ),
                  );
                },
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

  Widget _buildLinkTile(BuildContext context, String title, String target, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dishTvOrange),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: () async {
        if (target.startsWith('/')) { // Check if it's an internal route
          Navigator.pushNamed(context, target);
        } else {
          final Uri uri = Uri.parse(target);
          if (!await launchUrl(uri)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch \$target')),
            );
          }
        }
      },
    );
  }
}
