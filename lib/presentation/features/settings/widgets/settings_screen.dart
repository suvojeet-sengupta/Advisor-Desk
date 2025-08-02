import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart'; // Import AppRouter
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/domain/usecases/delete_cq_entries_by_date_usecase.dart';

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
            'Data Management',
            [
              ListTile(
                title: const Text('Delete CQ Entries by Date'),
                subtitle: const Text('Delete all CQ entries for a selected date.'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () async {
                    final DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );

                    if (selectedDate != null) {
                      final bool confirmDelete = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text('Are you sure you want to delete all CQ entries for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}? This action cannot be undone.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      ) ?? false;

                      if (confirmDelete) {
                        final deleteCQEntriesByDateUseCase = RepositoryProvider.of<DeleteCQEntriesByDateUseCase>(context);
                        final int deletedCount = await deleteCQEntriesByDateUseCase.execute(selectedDate);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$deletedCount CQ entries deleted for ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}')),
                        );
                      }
                    }
                  },
                ),
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
