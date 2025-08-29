import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:advisor_desk/core/utils/authentication_service.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_button.dart';
import 'package:simple_animations/simple_animations.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({Key? key, required this.onUnlocked}) : super(key: key);

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with TickerProviderStateMixin {
  bool _isBiometricAvailable = false;
  final _pinController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    super.dispose();
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
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox.shrink(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 64,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'App Locked',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          if (_isBiometricAvailable)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.fingerprint, color: Colors.white),
                                label: const Text('Unlock with Biometrics', style: TextStyle(color: Colors.white)),
                                onPressed: _authenticateWithBiometrics,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: TextField(
                                  controller: _pinController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  obscureText: true,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 24, letterSpacing: 16, color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Enter PIN',
                                    labelStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                    counterText: "",
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: 'Unlock',
                              onPressed: _authenticateWithPin,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Text(
                          'Protected By Advisor Desk',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<String>()
      ..add("color1", ColorTween(begin: const Color(0xffD38312), end: const Color(0xffA83279)))
      ..add("color2", ColorTween(begin: const Color(0xff000000), end: const Color(0xff000000)));

    return MirrorAnimation<MultiTweenValues<String>>(
      tween: tween,
      duration: const Duration(seconds: 3),
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                value.get("color1"),
                value.get("color2"),
              ],
            ),
          ),
        );
      },
    );
  }
}
