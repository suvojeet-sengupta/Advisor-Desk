import 'package:flutter/material.dart';
import 'package:advisor_desk/core/utils/authentication_service.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({Key? key, required this.onUnlocked}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isBiometricAvailable = false;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final isAvailable = await AuthenticationService.isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
    // Automatically trigger biometric auth if available
    if (isAvailable) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final isAuthenticated = await AuthenticationService.authenticateWithBiometrics();
    if (isAuthenticated) {
      widget.onUnlocked();
    }
  }

  Future<void> _authenticateWithPin() async {
    final pin = _pinController.text;
    if (pin.isEmpty) return;

    final isValid = await AuthenticationService.checkPin(pin);
    if (isValid) {
      widget.onUnlocked();
    } else {
      _pinController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'App Locked',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              if (_isBiometricAvailable)
                OutlinedButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with Biometrics'),
                  onPressed: _authenticateWithBiometrics,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 16),
                decoration: const InputDecoration(
                  labelText: 'Enter PIN',
                  border: OutlineInputBorder(),
                  counterText: "",
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Unlock',
                onPressed: _authenticateWithPin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
