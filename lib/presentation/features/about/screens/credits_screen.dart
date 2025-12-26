import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Credits'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeroSection(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Special Thanks To'),
            _buildContributorsList(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Community & Testers'),
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                'A huge thank you to the Sky device community for their invaluable support on the tester side. Your feedback has been instrumental in improving this app.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.grey),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Friends & Supporters'),
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Many thanks to all my friends who provided their valuable feedback and support throughout the development process. Your encouragement has been a driving force.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.grey),
                textAlign: TextAlign.justify,
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeroSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Made with Love',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Advisor Desk',
             style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Widget _buildContributorsList(BuildContext context) {
    final names = [
      'Sudhanshu',
      'Dheeraj Ravidas',
      'Mouma Sengupta',
      'Asia Noori',
    ];
    
    // Using a predefined color loop for avatars
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
    ];

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: names.asMap().entries.map((entry) {
          final index = entry.key;
          final name = entry.value;
          final isLast = index == names.length - 1;
          
          return Column(
            children: [
              ListTile(
                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                 leading: CircleAvatar(
                   backgroundColor: colors[index % colors.length].withOpacity(0.1),
                   child: Text(
                     name[0].toUpperCase(),
                     style: TextStyle(color: colors[index % colors.length], fontWeight: FontWeight.bold),
                   ),
                 ),
                 title: Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              if (!isLast)
                 Divider(height: 1, indent: 20, endIndent: 20, color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ],
          );
        }).toList(),
      ),
    );
  }
}
