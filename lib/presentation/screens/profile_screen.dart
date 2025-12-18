import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_form_field.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/data/repositories/profile_repository_impl.dart';
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

class ProfileScreen extends StatelessWidget {
  final bool isMandatoryFill;
  const ProfileScreen({Key? key, this.isMandatoryFill = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileView(isMandatoryFill: isMandatoryFill);
  }
}

class ProfileView extends StatefulWidget {
  final bool isMandatoryFill;
  const ProfileView({Key? key, this.isMandatoryFill = false}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profileCubit = context.read<ProfileCubit>();
    _nameController = TextEditingController(text: profileCubit.state.profile.name);
    _companyController = TextEditingController(text: profileCubit.state.profile.companyName);

    if (widget.isMandatoryFill) {
      profileCubit.setEditing(true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<ProfileCubit>().updateProfilePicture(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (!state.isEditing) {
          _nameController.text = state.profile.name ?? '';
          _companyController.text = state.profile.companyName ?? '';
        }
      },
      builder: (context, state) {
        final language = context.watch<LanguageCubit>().state;
        return Scaffold(
          appBar: CustomAppBar(
            title: state.isEditing ? AppStrings.get(language, 'edit_profile_title') : AppStrings.get(language, 'profile_title'),
            actions: [
              if (!state.isEditing && !widget.isMandatoryFill)
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => context.read<ProfileCubit>().setEditing(true),
                )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              children: [
                _buildProfileHeader(context, state.profile, state.isEditing),
                const SizedBox(height: 40),
                state.isEditing
                    ? _buildEditView(context, state.profile, language)
                    : _buildInfoView(context, state.profile, language),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Profile profile, bool isEditing) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 3),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: primaryColor.withOpacity(0.1),
              backgroundImage: profile.profilePicturePath.isNotEmpty
                  ? FileImage(File(profile.profilePicturePath))
                  : null,
              child: profile.profilePicturePath.isEmpty
                  ? Icon(Icons.person_rounded, size: 60, color: primaryColor)
                  : null,
            ),
          ),
          if (isEditing)
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: FloatingActionButton(
                mini: true,
                onPressed: _pickImage,
                backgroundColor: primaryColor,
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoView(BuildContext context, Profile profile, Language language) {
    return Column(
      children: [
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
               ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.person_outline_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(AppStrings.get(language, 'name_label'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                subtitle: Row(
                  children: [
                    Text(
                      profile.name ?? AppStrings.get(language, 'not_set_label'), 
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (profile.name == 'Suvojeet Sengupta') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DEV',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business_center_outlined, color: Colors.orange),
                ),
                title: Text(AppStrings.get(language, 'company_label'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                subtitle: Text(
                  profile.companyName ?? AppStrings.get(language, 'not_set_label'), 
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        CustomCard(
           onTap: () {
            Navigator.pushNamed(context, AppRouter.userManagementRoute);
           },
           child: Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(Icons.people_outline_rounded, color: Theme.of(context).colorScheme.secondary),
               ),
               const SizedBox(width: 16),
               Text(AppStrings.get(language, 'manage_users_label'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
               const Spacer(),
               Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
             ],
           ),
        ),
      ],
    );
  }

  Widget _buildEditView(BuildContext context, Profile profile, Language language) {
    return Column(
      children: [
        CustomFormField(
          label: AppStrings.get(language, 'name_label'),
          hintText: AppStrings.get(language, 'enter_name_hint'),
          controller: _nameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 24),
        CustomFormField(
          label: AppStrings.get(language, 'company_name_label'),
          hintText: AppStrings.get(language, 'enter_company_hint'),
          controller: _companyController,
          icon: Icons.business_rounded,
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: AnimatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final companyName = _companyController.text.trim();
  
              if (name.isEmpty || companyName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.get(language, 'name_company_empty_error'))),
                );
                return;
              }
  
              final updatedProfile = profile.copyWith(
                name: name,
                companyName: companyName,
              );
              context.read<ProfileCubit>().saveProfile(updatedProfile);
  
              if (widget.isMandatoryFill) {
                Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
              }
            },
            child: Text(AppStrings.get(language, 'save_profile')),
          ),
        ),
        if (!widget.isMandatoryFill) ...[
          const SizedBox(height: 16),
          TextButton(
             onPressed: () => context.read<ProfileCubit>().setEditing(false),
             child: Text(AppStrings.get(language, 'cancel')),
          ),
        ],
      ],
    );
  }
}
