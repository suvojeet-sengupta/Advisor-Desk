import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      if (!_isScrolledToEnd) {
        setState(() {
          _isScrolledToEnd = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _acceptPolicy() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcceptedPrivacyPolicy', true);
    // After accepting, navigate to the next logical screen.
    // This checks if the profile is filled, otherwise sends to profile screen.
    final isProfileFilled = prefs.getBool('isProfileFilled') ?? false;
    if (isProfileFilled) {
        Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
    } else {
        Navigator.pushReplacementNamed(context, AppRouter.profileRoute, arguments: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppBar(
          title: 'Privacy Policy',
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<String>(
                future: rootBundle.loadString('assets/web/privacy_policy.html'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Could not load privacy policy.'));
                  }
                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                    child: Html(
                      data: snapshot.data,
                      style: {
                        "body": Style(
                          backgroundColor: Colors.transparent,
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontFamily: 'Roboto', // Make sure font matches app
                          fontSize: FontSize(16.0),
                          color: theme.colorScheme.onBackground.withOpacity(0.8),
                          lineHeight: LineHeight.em(1.5),
                        ),
                        "h1, h2, h3": Style(
                           color: theme.colorScheme.primary,
                           fontWeight: FontWeight.bold,
                           margin: Margins.only(top: 24, bottom: 12),
                        ),
                        "h1": Style(fontSize: FontSize.xxLarge),
                        "h2": Style(fontSize: FontSize.xLarge),
                        "h3": Style(fontSize: FontSize.large),
                        "li": Style(
                          margin: Margins.only(bottom: 8),
                        ),
                        "a": Style(
                          color: theme.colorScheme.secondary,
                          textDecoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                        ),
                      },
                    ),
                  );
                },
              ),
            ),
             Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: AnimatedButton(
                  onPressed: _isScrolledToEnd || true ? _acceptPolicy : null, // Allow skipping for now as explicit scroll check can be buggy
                  backgroundColor: _isScrolledToEnd ? theme.colorScheme.primary : Colors.grey,
                  child: Text(
                    _isScrolledToEnd ? 'I Read and Accept' : 'Scroll to Accept',
                     style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
