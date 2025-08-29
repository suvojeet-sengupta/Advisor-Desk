import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({Key? key}) : super(key: key);

  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Set Your PIN'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a 4-digit PIN to secure your app.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter PIN',
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                validator: (value) {
                  if (value == null || value.length != 4) {
                    return 'PIN must be 4 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm PIN',
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
                validator: (value) {
                  if (value != _pinController.text) {
                    return 'PINs do not match';
                  }
                  return null;
                },
              ),
              const Spacer(),
              CustomButton(
                text: 'Save PIN',
                onPressed: _savePin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePin() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_pin', _pinController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN saved successfully!')),
      );
      Navigator.pop(context, true); // Return true on success
    }
  }
}
