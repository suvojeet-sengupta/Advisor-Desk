import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/localization/app_strings.dart';
import 'package:advisor_desk/core/localization/language_cubit.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({Key? key}) : super(key: key);

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.read<LanguageCubit>().state;
    return AlertDialog(
      title: Text(AppStrings.get(language, 'add_new_user_title')),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: AppStrings.get(language, 'user_name_label'),
          hintText: AppStrings.get(language, 'enter_user_name_hint'),
          border: const OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.get(language, 'cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, name);
            }
          },
          child: Text(AppStrings.get(language, 'add_btn')),
        ),
      ],
    );
  }
}
