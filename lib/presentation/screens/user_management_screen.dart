import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/features/user/bloc/user_cubit.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/add_user_dialog.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Manage Users'),
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
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isCurrentUser = user.id == state.currentUserId;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCurrentUser
                        ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentUser ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: isCurrentUser ? const Text('Current User') : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isCurrentUser)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(context, user.name, () {
                                context.read<UserCubit>().deleteUser(user.id);
                              });
                            },
                          ),
                        if (isCurrentUser)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          ElevatedButton(
                            onPressed: () {
                              _showSwitchConfirmation(context, user.name, () async {
                                await context.read<UserCubit>().switchUser(user.id);
                                
                                // Check if profile is filled
                                final profileState = context.read<ProfileCubit>().state;
                                final isProfileFilled = profileState.profile.name != null && profileState.profile.companyName != null;
                                
                                if (!isProfileFilled) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context, 
                                    AppRouter.profileRoute, 
                                    (route) => false,
                                    arguments: true // isMandatoryFill
                                  );
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context, 
                                    AppRouter.dashboardRoute, 
                                    (route) => false
                                  );
                                }
                              });
                            },
                            child: const Text('Switch'),
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
        tooltip: 'Add User',
      ),
    );
  }

  void _showSwitchConfirmation(BuildContext context, String userName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch User'),
        content: Text('Are you sure you want to switch to $userName? The app will reload with their data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }
  void _showDeleteConfirmation(BuildContext context, String userName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
