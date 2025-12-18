import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/features/user/bloc/user_cubit.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/add_user_dialog.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageCubit>().state;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: AppStrings.get(language, 'manage_users_title')),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            return ListView.separated(
              padding: const EdgeInsets.all(20.0),
              itemCount: state.users.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isCurrentUser = user.id == state.currentUserId;

                return CustomCard(
                  padding: EdgeInsets.zero,
                  // Improve border logic in CustomCard if possible, otherwise use wrapping container logic
                  // Here we rely on the internal Container of CustomCard. 
                  // If we need specific border for current user, we might need a wrapper.
                  // For now, let's use a colored header or icon to denote current user clearly.
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isCurrentUser 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.transparent, 
                            width: 2
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: isCurrentUser 
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.1) 
                            : Colors.grey.withOpacity(0.1),
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: isCurrentUser 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    subtitle: isCurrentUser 
                        ? Text(
                            AppStrings.get(language, 'active_session_label'), 
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12)
                          ) 
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isCurrentUser)
                          IconButton(
                            icon: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
                            onPressed: () {
                              _showDeleteConfirmation(context, user.name, () {
                                context.read<UserCubit>().deleteUser(user.id);
                              }, language);
                            },
                          ),
                        if (isCurrentUser)
                          Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary),
                        if (!isCurrentUser)
                          TextButton(
                             onPressed: () {
                              _showSwitchConfirmation(context, user.name, () async {
                                await context.read<UserCubit>().switchUser(user.id);
                                
                                final profileState = context.read<ProfileCubit>().state;
                                final isProfileFilled = profileState.profile.name != null && profileState.profile.companyName != null;
                                
                                if (!isProfileFilled) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context, 
                                    AppRouter.profileRoute, 
                                    (route) => false,
                                    arguments: true
                                  );
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context, 
                                    AppRouter.dashboardRoute, 
                                    (route) => false
                                  );
                                }
                              }, language);
                            },
                             child: Text(AppStrings.get(language, 'switch_btn')),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<String>(
            context: context,
            builder: (context) => const AddUserDialog(),
          );
          if (result != null && result.isNotEmpty) {
            context.read<UserCubit>().addUser(result);
          }
        },
        child: const Icon(Icons.add),
        tooltip: AppStrings.get(language, 'add_user_tooltip'),
      ),
    );
  }

  void _showSwitchConfirmation(BuildContext context, String userName, VoidCallback onConfirm, Language language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get(language, 'switch_user_title')),
        content: Text(AppStrings.get(language, 'switch_user_message').replaceAll('{userName}', userName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get(language, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(AppStrings.get(language, 'switch_btn')),
          ),
        ],
      ),
    );
  }
  void _showDeleteConfirmation(BuildContext context, String userName, VoidCallback onConfirm, Language language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.get(language, 'delete_user_title')),
        content: Text(AppStrings.get(language, 'delete_user_message').replaceAll('{userName}', userName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.get(language, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(AppStrings.get(language, 'delete')),
          ),
        ],
      ),
    );
  }
}
