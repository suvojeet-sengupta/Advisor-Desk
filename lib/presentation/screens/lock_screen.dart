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
    if (isAvailable) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final isAuthenticated =
        await AuthenticationService.authenticateWithBiometrics();
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF2C3E50), const Color(0xFF000000)]
                : [const Color(0xFFECE9E6), const Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon/app_icon.png',
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your PIN to unlock Advisor Desk',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (_isBiometricAvailable)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: GestureDetector(
                          onTap: _authenticateWithBiometrics,
                          child: Column(
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 60,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Unlock with Biometrics',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 250,
                      child: TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          letterSpacing: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 250,
                      child: CustomButton(
                        text: 'Unlock',
                        onPressed: _authenticateWithPin,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Protected By Advisor Desk',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white54 : Colors.black45,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
