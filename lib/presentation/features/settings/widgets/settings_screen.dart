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
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart'; // Import CustomCard
import 'package:advisor_desk/data/datasources/ad_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:share_plus/share_plus.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Settings'),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildSectionHeader('General'),
              _buildSectionCard(
                context,
                [
                   FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                         return _buildSettingsTile(
                              context,
                              icon: Icons.info_outline_rounded,
                              title: 'App Version',
                              subtitle: '${snapshot.data!.version} (${snapshot.data!.buildNumber})',
                              onTap: null,
                            );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    context,
                    icon: Icons.new_releases_rounded,
                    title: "What's New",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ChangelogDialog(),
                      );
                    },
                  ),
                   _buildDivider(),
                  _buildLinkTile(
                    context,
                    'About App',
                    AppRouter.aboutAppRoute,
                    Icons.business_rounded,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Feedback'),
              _buildSectionCard(
                context,
                [
                   _buildRateTheAppSection(context),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Data'),
              _buildSectionCard(
                context,
                [
                  _buildDataManagementTile(
                    context,
                    'Backup Data',
                    _lastBackupDate != null ? 'Last backup: $_lastBackupDate' : 'Save your data locally',
                    Icons.backup_rounded,
                    _backupDatabase,
                  ),
                   _buildDivider(),
                  _buildDataManagementTile(
                    context,
                    'Restore Data',
                    'Restore from a backup file',
                    Icons.restore_rounded,
                    _restoreDatabase,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Preferences'),
              _buildSectionCard(
                context,
                [
                   _buildLinkTile(
                    context,
                    'Salary Parameters',
                    AppRouter.salarySettingsRoute,
                    Icons.attach_money_rounded,
                  ),
                   _buildDivider(),
                  _buildLinkTile(
                    context,
                    'Customize Dashboard',
                    AppRouter.customizeDashboardRoute,
                    Icons.dashboard_customize_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionHeader('Security & Privacy'),
              _buildSectionCard(
                context,
                [
                  _buildAppLockTile(),
                  if (_isAppLockEnabled) ...[
                     _buildDivider(),
                    _buildLinkTile(
                      context,
                      'App Lock Settings',
                      AppRouter.appLockSettingsRoute,
                      Icons.lock_person_rounded,
                    ),
                  ],
                   _buildDivider(),
                  _buildLinkTile(
                    context,
                    'Privacy Policy',
                    'https://suvojeet-sengupta.github.io/Privacy_policy_Advisor_Desk/',
                    Icons.privacy_tip_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.1));
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey) : null,
      onTap: onTap,
    );
  }
  
  // Reusing _buildSettingsTile logic for others to keep consistent design
  Widget _buildLinkTile(BuildContext context, String title, String target, IconData icon) {
     return _buildSettingsTile(
       context,
       icon: icon,
       title: title,
       onTap: () async {
        if (target.startsWith('/')) {
          Navigator.pushNamed(context, target);
        } else {
          final Uri uri = Uri.parse(target);
          if (!await launchUrl(uri)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $target')),
            );
          }
        }
       }
     );
  }

  Widget _buildDataManagementTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
      return _buildSettingsTile(
        context,
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      );
  }
  
  Widget _buildAppLockTile() {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.fingerprint_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
      ),
      title: const Text('App Lock', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: const Text('Secure app access', style: TextStyle(fontSize: 12)),
      value: _isAppLockEnabled,
      onChanged: (bool newValue) async {
        if (newValue) {
          final pinWasSet = await Navigator.pushNamed(context, AppRouter.pinSetupRoute);
          if (pinWasSet == true) {
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
    );
  }
  
  Widget _buildRateTheAppSection(BuildContext context) {
      return _buildSettingsTile(
        context,
        icon: Icons.star_rate_rounded,
        title: 'Rate the App',
        onTap: () => _showSatisfactionDialog(context),
      );
  }
  
  // Logic Methods
  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _loadAppLockState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAppLockEnabled = prefs.getBool('isAppLockEnabled') ?? false;
    });
  }

  Future<void> _loadLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastBackupDate = prefs.getString('last_backup_date');
    });
  }

  Future<void> _backupDatabase() async {
    setState(() => _isLoading = true);
    try {
      final repository = context.read<PerformanceRepository>();
      final backupPath = await repository.backupDatabase();

      if (backupPath.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final now = DateTime.now();
        final formattedDate = '${now.year}-${now.month}-${now.day} ${now.hour}:${now.minute}';
        await prefs.setString('last_backup_date', formattedDate);
        setState(() {
          _lastBackupDate = formattedDate;
        });

        // Share the backup file
        await Share.shareXFiles([XFile(backupPath)], text: 'Advisor Desk Backup');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restoreDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() => _isLoading = true);
      try {
        final repository = context.read<PerformanceRepository>();
        await repository.restoreDatabase(result.files.single.path!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore successful! Please restart the app.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showSatisfactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you satisfied with the app?'),
        content: const Text('We would love to hear your feedback!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
               // Show feedback form or email
               // For now just close
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final InAppReview inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              } else {
                 final Uri uri = Uri.parse('market://details?id=com.suvojeet.advisordesk'); // Replace with your package name
                 launchUrl(uri);
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
