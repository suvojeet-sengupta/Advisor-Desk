import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for MethodChannel and PlatformException
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';

class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  String _appVersion = 'Loading...';
  static const platform = MethodChannel('com.suvojeet.advisordesk/app_info');

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      final String version = await platform.invokeMethod('getAppVersion');
      setState(() {
        _appVersion = version;
      });
    } on PlatformException catch (e) {
      setState(() {
        _appVersion = 'Error: ${e.message}';
      });
    }
  }

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
                    "Version: $_appVersion", // Use the fetched version
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
                          ),
                    ),
                    onTap: () => _launchURL('https://github.com/suvojit213/Advisor-Desk'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.people, color: AppColors.dishTvOrangeLight),
                    title: Text(
                      'Credits',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.dishTvOrange,
                          ),
                    ),
                    onTap: () => Navigator.pushNamed(context, AppRouter.creditsRoute),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
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