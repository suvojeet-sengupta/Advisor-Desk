import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'App Info'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.dishTvOrange,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version: ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Developer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person, color: AppColors.dishTvOrangeLight),
                    title: Text(
                      'Suvojeet Sengupta',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: Icon(Icons.email, color: AppColors.dishTvOrangeLight),
                    title: Text(
                      'suvojitsengupta21@gmail.com',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.dishTvOrange,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                    onTap: () => _launchURL('mailto:suvojitsengupta21@gmail.com'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'App Source',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  ListTile(
                    leading: Icon(Icons.code, color: AppColors.dishTvOrangeLight),
                    title: Text(
                      'GitHub Repository',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.dishTvOrange,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                    onTap: () => _launchURL('https://github.com/suvojit213/Advisor-Desk'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Credits',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Special Thanks to Didi Bhai (Mouma), Sudhanshu & many others who contributed and helped me to complete this app.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"I Developed This App for Easy to Track Advisor Desk WFH Agent Performance Yourself, Thanks For using This Application"',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }
}