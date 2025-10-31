import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter/services.dart'; // Import for MethodChannel and PlatformException
import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart'; // Import AppRouter
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/usecases/delete_cq_entries_by_date_usecase.dart';
import 'package:advisor_desk/domain/usecases/delete_csat_entries_by_date_usecase.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Import PackageInfo
import 'package:advisor_desk/presentation/common/widgets/changelog_dialog.dart'; // Import ChangelogDialog
import 'package:advisor_desk/data/datasources/ad_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';
  static const platform = MethodChannel('com.suvojeet.advisordesk/app_info');
  bool _isAppLockEnabled = false;
  bool _isLoading = false;
  String? _lastBackupDate;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _loadAppLockState();
    _loadLastBackupDate();
  }

  // ... (rest of the class methods)

  Widget _buildRateTheAppSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.star_rate),
      title: const Text('Rate the App'),
      onTap: () => _showSatisfactionDialog(context),
    );
  }

  void _showSatisfactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Are you satisfied with this app?'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_satisfied_alt, size: 48, color: Colors.green),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _requestReview();
                    },
                  ),
                  const Text('Yes'),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _showSuggestionDialog(context);
                    },
                  ),
                  const Text('No'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _requestReview() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      // Optionally, direct to app store if in-app review is not available
      // For Android, you can use:
      // launchUrl(Uri.parse('market://details?id=<your_package_name>'));
      // For iOS, you can use:
      // launchUrl(Uri.parse('itunes.apple.com/app/id<your_app_id>'));
    }
  }

  void _showSuggestionDialog(BuildContext context) {
    final TextEditingController _suggestionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Send Suggestion'),
          content: TextField(
            controller: _suggestionController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Enter your suggestion here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_suggestionController.text.isNotEmpty) {
                  _sendEmail(context, _suggestionController.text);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmail(BuildContext context, String suggestion) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'suvojeetsengupta@zohomail.in',
      queryParameters: {
        'subject': 'App Suggestion',
        'body': suggestion,
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app.')),
      );
    }
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  Future<void> _loadLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastBackupDate = prefs.getString('lastBackupDate');
    });
  }

  Future<void> _loadAppLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAppLockEnabled = prefs.getBool('isAppLockEnabled') ?? false;
    });
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

  Future<void> _backupDatabase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final repository = context.read<PerformanceRepository>();
      final tempBackupPath = await repository.backupDatabase();
      final tempBackupFile = File(tempBackupPath);

      final fileBytes = await tempBackupFile.readAsBytes();

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Your Backup',
        fileName: 'advisor_desk_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
        bytes: fileBytes,
      );

      if (outputFile != null) {
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        final formattedDate = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}";
        await prefs.setString('lastBackupDate', formattedDate);
        setState(() {
          _lastBackupDate = formattedDate;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to $outputFile')),
        );
        await context.read<AdService>().showAd();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup cancelled.')),
        );
      }
      await tempBackupFile.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreDatabase() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        final backupFilePath = result.files.single.path!;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Restore Database'),
            content: const Text('Are you sure you want to restore the database? This will overwrite all current data.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the confirmation dialog first
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final repository = context.read<PerformanceRepository>();
                    await repository.restoreDatabase(backupFilePath);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database restored successfully. Please restart the app.')),
                    );
                    await context.read<AdService>().showAd();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restore failed: $e')),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: const Text('Restore'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [

              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                'App Information',
                [
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            _buildSettingsTile(
                              context,
                              icon: Icons.verified,
                              title: 'App Version',
                              subtitle: '${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                              onTap: null,
                            ),
                            _buildSettingsTile(
                              context,
                              icon: Icons.new_releases,
                              title: "What's New",
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => ChangelogDialog(),
                                );
                              },
                            ),
                            _buildLinkTile(
                              context,
                              'About App',
                              AppRouter.aboutAppRoute, // This route will be renamed to aboutAppRoute
                              Icons.info_outline,
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                'Feedback',
                [
                  _buildRateTheAppSection(context),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                'Data Management',
                [
                  _buildDataManagementTile(
                    context,
                    'Backup Data',
                    _lastBackupDate != null ? 'Last backup: $_lastBackupDate' : 'Save your data to a file',
                    Icons.backup,
                    _backupDatabase,
                  ),
                  _buildDataManagementTile(
                    context,
                    'Restore Data',
                    'Restore your data from a file',
                    Icons.restore,
                    _restoreDatabase,
                  ),
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
                'Appearance',
                [
                  _buildLinkTile(
                    context,
                    'Customize Dashboard',
                    AppRouter.customizeDashboardRoute,
                    Icons.dashboard_customize,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                context,
                'Privacy & Security',
                [
                  _buildAppLockTile(),
                  if (_isAppLockEnabled)
                    _buildLinkTile(
                      context,
                      'App Lock Settings',
                      AppRouter.appLockSettingsRoute,
                      Icons.lock_clock,
                    ),
                  _buildLinkTile(
                    context,
                    'Privacy Policy',
                    'https://suvojeet-sengupta.github.io/Privacy_policy_Advisor_Desk/',
                    Icons.privacy_tip_outlined,
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
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
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, String target, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
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
              SnackBar(content: Text('Could not launch $target')),
            );
          }
        }
      },
    );
  }

  Widget _buildAppLockTile() {
    return SwitchListTile(
      title: const Text('App Lock'),
      subtitle: const Text('Secure app with PIN or Biometrics'),
      value: _isAppLockEnabled,
      onChanged: (bool newValue) async {
        if (newValue) {
          // If enabling, navigate to PIN setup and wait for a result
          final pinWasSet = await Navigator.pushNamed(context, AppRouter.pinSetupRoute);
          if (pinWasSet == true) {
            // Only enable if PIN was successfully set
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isAppLockEnabled', true);
            setState(() {
              _isAppLockEnabled = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('App Lock enabled.')),
            );
          }
        } else {
          // If disabling, just turn it off and clear data
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAppLockEnabled', false);
          await prefs.remove('app_pin');
          setState(() {
            _isAppLockEnabled = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App Lock disabled.')),
          );
        }
      },
      secondary: Icon(Icons.fingerprint, color: Theme.of(context).colorScheme.primary),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildDataManagementTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}