import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advisor_desk/presentation/routes/app_router.dart';

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
        appBar: AppBar(
          title: const Text('Privacy Policy'),
          automaticallyImplyLeading: false,
        ),
      body: FutureBuilder<String>(
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
            padding: const EdgeInsets.all(12.0),
            child: Html(
              data: snapshot.data,
              style: {
                "body": Style(
                  backgroundColor: Colors.transparent, // Use scaffold background
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "h1, h2, h3, p, li, a": Style(
                  color: const Color(0xFF333333),
                ),
                "h1": Style(color: theme.colorScheme.primary, fontSize: FontSize.xxLarge),
                "h2": Style(color: theme.colorScheme.primary, fontSize: FontSize.xLarge),
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isScrolledToEnd ? _acceptPolicy : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.withOpacity(0.5),
            ),
            child: Text(_isScrolledToEnd ? 'I Read and Accept' : 'Scroll to the end to accept'),
          ),
        ),
      ),
    ));
  }
}
