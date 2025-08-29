import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter/services.dart'; // Import for MethodChannel and PlatformException
import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart'; // Import AppRouter
import 'package:url_launcher/url_launcher.dart';
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = 'Loading...';
  static const platform = MethodChannel('com.suvojeet.advisordesk/app_info');
  bool _isAppLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _loadAppLockState();
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
    try {
      final repository = context.read<PerformanceRepository>();
      final tempBackupPath = await repository.backupDatabase();
      final tempBackupFile = File(tempBackupPath);

      // Read the file as bytes
      final fileBytes = await tempBackupFile.readAsBytes();

      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Your Backup',
        fileName: 'advisor_desk_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
        bytes: fileBytes, // Pass the bytes here
      );

      if (outputFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to $outputFile')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup cancelled.')),
        );
      }
      await tempBackupFile.delete(); // Always delete the temporary file
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
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
                  try {
                    final repository = context.read<PerformanceRepository>();
                    await repository.restoreDatabase(backupFilePath);
                    Navigator.pop(context); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Database restored successfully. Please restart the app.')),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restore failed: $e')),
                    );
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionCard(
            context,
            'App Information',
            [
              _buildInfoTile('Version', _appVersion, Icons.info_outline),
              _buildLinkTile(
                context,
                'Credits',
                AppRouter.creditsRoute,
                Icons.people,
              ),
              _buildLinkTile(
                context,
                'GitHub Repository',
                'https://github.com/suvojit213/Advisor-Desk',
                Icons.code,
              ),
              ListTile(
                leading: Icon(Icons.email, color: Theme.of(context).colorScheme.secondary),
                title: Text(
                  'suvojitsengupta21@gmail.com',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                onTap: () => _launchURL('mailto:suvojitsengupta21@gmail.com'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
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
                'Save your data to a file',
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
            'Privacy & Security',
            [
              _buildAppLockTile(),
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
            'About Developer',
            [
              _buildLinkTile(
                context,
                'About Developer',
                AppRouter.aboutDeveloperRoute,
                Icons.person,
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