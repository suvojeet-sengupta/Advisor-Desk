import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'About App'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(
                context,
                'About the Developer',
                'Suvojeet Sengupta',
                'I am an Arts student with a deep passion for technology and a drive to solve real-world problems. By day, I work as a freelance BPO professional, and by night, I\'m a self-taught developer, always curious and eager to learn new things. This app is the result of my journey to combine my professional experience with my love for technology.',
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                'The Story Behind Advisor Desk',
                '',
                'As a customer care executive, I found it challenging to keep track of my daily calls, login hours, and performance scores. Since my salary is calculated on a per-call basis, I needed a way to monitor my progress and earnings in real-time, without having to wait for my payslip. I wanted to know exactly how many calls I needed to take to reach my target.\n\nTo solve this problem, I created Advisor Desk. This app is designed to help my fellow advisors and other professionals in similar roles to easily track their performance, calculate their earnings, and stay motivated to achieve their goals. It\'s a tool built by an advisor, for advisors.',
              ),
              const SizedBox(height: 24),
              _buildTeamSection(context),
              const SizedBox(height: 24),
              _buildGetInTouch(context),
              const SizedBox(height: 16), // Added for bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String subtitle, String content) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Our Team',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),
        _buildTeamCard(
          context,
          'Suvojeet Sengupta',
          'Core Developer',
        ),
        _buildTeamCard(
          context,
          'Sudhanshu',
          'Testing/Feedback Contributor',
        ),
        _buildTeamCard(
          context,
          'Dheeraj Ravidas',
          'Testing/Feedback Contributor',
        ),
        _buildTeamCard(
          context,
          'Mouma Sengupta',
          'Testing/Feedback Contributor',
        ),
        _buildTeamCard(
          context,
          'Asia Noori',
          'Testing/Feedback Contributor',
        ),
        _buildTeamCard(
          context,
          "And All others whose names I can't mention",
          'Contributors',
        ),
      ],
    );
  }

  Widget _buildTeamCard(BuildContext context, String name, String role) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  role,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          Icons.code,
        ),
        _buildLinkTile(
          context,
          'Instagram',
          'https://www.instagram.com/suvojeet__sengupta',
          Icons.camera_alt,
        ),
        _buildLinkTile(
          context,
          'Email',
          'mailto:suvojitsengupta21@gmail.com',
          Icons.email,
        ),
      ],
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, String url, IconData iconData) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(iconData, color: Theme.of(context).colorScheme.primary),
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

