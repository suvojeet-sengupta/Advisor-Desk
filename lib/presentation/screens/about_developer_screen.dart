import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperScreen extends StatelessWidget {
  const AboutDeveloperScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'About Developer'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suvojeet Sengupta',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildSection(
              context,
              'About the Developer',
              'I am an Arts student with a deep passion for technology and a drive to solve real-world problems. By day, I work as a freelance BPO professional, and by night, I\'m a self-taught developer, always curious and eager to learn new things. This app is the result of my journey to combine my professional experience with my love for technology.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'The Story Behind Advisor Desk',
              'As a customer care executive, I found it challenging to keep track of my daily calls, login hours, and performance scores. Since my salary is calculated on a per-call basis, I needed a way to monitor my progress and earnings in real-time, without having to wait for my payslip. I wanted to know exactly how many calls I needed to take to reach my target.\n\nTo solve this problem, I created Advisor Desk. This app is designed to help my fellow advisors and other professionals in similar roles to easily track their performance, calculate their earnings, and stay motivated to achieve their goals. It\'s a tool built by an advisor, for advisors.',
            ),
            const SizedBox(height: 24),
            _buildGetInTouch(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get in Touch',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'I am always looking for ways to improve Advisor Desk. If you have any questions, bug reports, or feature requests, please feel free to contact me. I am always happy to hear from you and work together to make this app the best it can be.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 16),
        _buildLinkTile(
          context,
          'GitHub',
          'https://github.com/suvojeet-sengupta',
          SvgPicture.asset(
            'assets/images/github_logo.svg',
            height: 24,
            width: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        _buildLinkTile(
          context,
          'Instagram',
          'https://www.instagram.com/suvojeet__sengupta',
          SvgPicture.asset(
            'assets/images/instagram_logo.svg',
            height: 24,
            width: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        _buildLinkTile(
          context,
          'Email',
          'mailto:suvojitsengupta21@gmail.com',
          Icon(Icons.email, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, String url, Widget icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: icon,
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _launchURL(url),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
