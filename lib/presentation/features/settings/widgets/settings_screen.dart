import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/domain/repositories/performance_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:advisor_desk/data/datasources/data_import_service.dart';
import 'package:advisor_desk/data/datasources/local_data_source.dart';
import 'package:advisor_desk/domain/usecases/import_data_usecase.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data Management',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Removed CSV import buttons
            Text(
              'App Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Version: ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Legal',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse('https://suvojit213.github.io/Privacy_policy_Advisor_Desk/');
                if (!await launchUrl(url)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not launch privacy policy link.')),
                  );
                }
              },
              child: Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed _importData method

  

  Future<void> _backupData(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backing up data...')),
    );
    try {
      final repo = context.read<PerformanceRepository>();
      final backupPath = await repo.backupDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data backed up to: $backupPath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    // This is a simplified example. In a real app, you'd want a file picker.
    // For now, let's assume the backup file is in a known location or user selects it.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restoring data... (Manual file selection needed in real app)')),
    );
    try {
      final repo = context.read<PerformanceRepository>();
      // Placeholder for actual file selection
      // You would typically use a package like file_picker to let the user select a file
      // For demonstration, let's assume a file named 'advisor_desk.db_backup_TIMESTAMP.db' exists in external storage
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw Exception("Could not get external storage directory.");
      }
      // This path needs to be dynamic based on the actual backup file name
      final backupFilePath = '${externalDir.path}/advisor_desk.db_backup_YOUR_TIMESTAMP.db'; // REPLACE WITH ACTUAL BACKUP FILE

      // Check if the placeholder file exists
      if (!await File(backupFilePath).exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup file not found at assumed path. Please select manually in a real app.')),
        );
        return;
      }

      await repo.restoreDatabase(backupFilePath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data restored successfully! Please restart the app.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    }
  }
}