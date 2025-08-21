import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:advisor_desk/presentation/features/profile/bloc/profile_cubit.dart';
import 'package:advisor_desk/domain/entities/profile.dart';
import 'package:advisor_desk/data/repositories/profile_repository_impl.dart';
import 'package:advisor_desk/data/datasources/profile_data_source.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  final bool isMandatoryFill;
  const ProfileScreen({Key? key, this.isMandatoryFill = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        ProfileRepositoryImpl(ProfileDataSource()),
      ),
      child: ProfileView(isMandatoryFill: isMandatoryFill),
    );
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
        _nameController.text = state.profile.name ?? '';
        _companyController.text = state.profile.companyName ?? '';
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: state.isEditing ? 'Edit Profile' : 'Profile'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileHeader(context, state.profile, state.isEditing),
                const SizedBox(height: 24),
                state.isEditing
                    ? _buildEditView(context, state.profile)
                    : _buildInfoView(context, state.profile),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Profile profile, bool isEditing) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 80,
          backgroundImage: profile.profilePicturePath.isNotEmpty
              ? FileImage(File(profile.profilePicturePath))
              : null,
          child: profile.profilePicturePath.isEmpty
              ? const Icon(Icons.person, size: 80)
              : null,
        ),
        if (isEditing)
          FloatingActionButton(
            mini: true,
            onPressed: _pickImage,
            child: const Icon(Icons.camera_alt),
          ),
      ],
    );
  }

  Widget _buildInfoView(BuildContext context, Profile profile) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Name'),
                  subtitle: Text(profile.name ?? 'Not Set', style: Theme.of(context).textTheme.titleLarge),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.business_center_outlined),
                  title: const Text('Company'),
                  subtitle: Text(profile.companyName ?? 'Not Set', style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Edit Profile',
          onPressed: () {
            context.read<ProfileCubit>().setEditing(true);
          },
        ),
      ],
    );
  }

  Widget _buildEditView(BuildContext context, Profile profile) {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    hintText: 'Enter your company name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Save Profile',
          onPressed: () async {
            final name = _nameController.text.trim();
            final companyName = _companyController.text.trim();

            if (name.isEmpty || companyName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Name and Company Name cannot be empty.')),
              );
              return; // Prevent saving if fields are empty
            }

            final updatedProfile = profile.copyWith(
              name: name,
              companyName: companyName,
            );
            context.read<ProfileCubit>().saveProfile(updatedProfile);

            // Set hasFilledProfileInfo to true
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('hasFilledProfileInfo', true);

            // Navigate to dashboard if it was a mandatory fill
            if (widget.isMandatoryFill) {
              Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
            }
          },
        ),
      ],
    );
  }
}
