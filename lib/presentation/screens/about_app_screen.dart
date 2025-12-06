import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'About Advisor Desk'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(
                context,
                'About the Developer',
                'Suvojeet Sengupta',
                'I am an Arts student with a deep passion for technology and a drive to solve real-world problems. By day, I work as a freelance BPO professional, and by night, I\'m a self-taught developer, always curious and eager to learn new things. This app is the result of my journey to combine my professional experience with my love for technology.',
                isPrimary: true,
              ),
              const SizedBox(height: 20),
              _buildInfoCard(
                context,
                'The Story',
                null,
                'As a customer care executive, I found it challenging to keep track of my daily calls, login hours, and performance scores. Since my salary is calculated on a per-call basis, I needed a way to monitor my progress and earnings in real-time, without having to wait for my payslip.\n\nTo solve this problem, I created Advisor Desk. This app is designed to help my fellow advisors and other professionals in similar roles to easily track their performance, calculate their earnings, and stay motivated to achieve their goals. It\'s a tool built by an advisor, for advisors.',
              ),
              const SizedBox(height: 32),
              _buildTeamSection(context),
              const SizedBox(height: 32),
              _buildGetInTouch(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String? subtitle, String content, {bool isPrimary = false}) {
    return CustomCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            'Meet Existing Team',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        _buildTeamCard(
          context,
          'Suvojeet Sengupta',
          'Core Developer',
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPM_tMOSd7vXc3vObaXRrxmeL9baXeALYgAlrop2VoYSGX2OY1zzglX7mr&s=10',
        ),
        _buildTeamCard(
          context,
          'Sudhanshu',
          'Testing/Feedback Contributor',
          'https://lh3.googleusercontent.com/pw/AP1GczOQYDvK3kSFGZG8bz_YR-rjI94MJZBaqSQJnVjClytvOq2neAZlOzc5BUbnbtYFkO5wMlosV88_7W0gEEDdcC7d0m_xI0oRmWST3XTfmAFpOOycomemNsCSBR9OgvLuFfLwSh4DPANVesmuksha_wS-_w=w1081-h1441-s-no-gm?authuser=0',
        ),
        _buildTeamCard(
          context,
          'Dheeraj Ravidas',
          'Testing/Feedback Contributor',
          'https://lh3.googleusercontent.com/pw/AP1GczOU2y1Ip7FH7n22QDDbc63FLaIyE2fV7XSC52KIMD6HhBgs3-SITX6FXQre3MpJ9u_5FOqxWjLSkosnVVo_0Wy90prYAE9ljMJ_xmN-sYvlxvMFzpLQDLHKAACEzvQSt-MNoE8WG0croMVgB4VV2S2bZg=w1080-h1080-s-no-gm?authuser=0',
        ),
        _buildTeamCard(
          context,
          'Mouma Sengupta',
          'Testing/Feedback Contributor',
          'https://lh3.googleusercontent.com/pw/AP1GczNm0taRsJ8YhQJlaTpopdGXIoPlTyKLzAAeVA9g4eCptd4kagBqgVekniedgAGbfB_ipDmFplDxaUOviunTP-qRGYSwJjrXo9bm0wDQA-H2K5Lm3F4FSlNMif01ihAZBtyVhFa1ItAuCuuGN9TNqlsxwg=w1081-h1081-s-no-gm?authuser=0',
        ),
        _buildTeamCard(
          context,
          'Asia Noori',
          'Testing/Feedback Contributor',
        ),
        _buildTeamCard(
          context,
          'Vidhya Mandloi',
          'Testing/Feedback Contributor',
          'https://lh3.googleusercontent.com/pw/AP1GczMDvLyxiH3nhGETQbNv2T5DwiyElg_DyU4S2K_uMACEc64tQcFbKG6bwUIjl_7h3Xnvlk3TsdTUbAtN1aP_n1d6vzhSS3Mmj5qUl4Emlr6NMC71tq_EyqPKVDlsJLT1oF1UpxwnN1yHO9dEQaKmG1fsNQ=w634-h702-s-no-gm?authuser=0',
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '❤️ Thanks to all contributors!',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(BuildContext context, String name, String role, [String? imageUrl]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: CustomCard(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildProfileAvatar(context, name, imageUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (name == 'Suvojeet Sengupta') ...[
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
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String name, String? imageUrl) {
    // Note: Kept specific name check as requested in original code, but improved styling
    if ((name == 'Suvojeet Sengupta' || name == 'Dheeraj Ravidas' || name == 'Mouma Sengupta' || name == 'Sudhanshu' || name == 'Vidhya Mandloi') && imageUrl != null) {
      return FutureBuilder<List<ConnectivityResult>>(
        future: Connectivity().checkConnectivity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              !snapshot.data!.contains(ConnectivityResult.none)) {
            return Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else {
             return _buildPlaceholderAvatar(context);
          }
        },
      );
    } else {
      return _buildPlaceholderAvatar(context);
    }
  }

  Widget _buildPlaceholderAvatar(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
          child: Text(
            'Get in Touch',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Text(
          'I am always looking for ways to improve Advisor Desk. If you have any questions, bug reports, or feature requests, please feel free to contact me.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildLinkTile(
                context,
                'GitHub',
                'https://github.com/suvojeet-sengupta',
                Icons.code,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLinkTile(
                context,
                'Instagram',
                'https://www.instagram.com/suvojeet__sengupta',
                Icons.camera_alt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLinkTile(
          context,
          'Email Me',
          'mailto:suvojitsengupta21@gmail.com',
          Icons.email_outlined,
        ),
      ],
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, String url, IconData iconData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Icon(iconData, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Handle error gracefully or debug log
      debugPrint('Could not launch $url');
    }
  }
}

