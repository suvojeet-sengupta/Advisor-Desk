import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

/// A screen that displays a tutorial for the user, showcasing the app's features.
///
/// This screen uses a [PageView] to guide the user through different
/// functionalities of the Advisor Desk application. It includes navigation
/// controls to move between pages and a finish button to close the tutorial.
class OnboardingTutorialScreen extends StatefulWidget {
  /// Creates an [OnboardingTutorialScreen].
  const OnboardingTutorialScreen({super.key});

  @override
  State<OnboardingTutorialScreen> createState() =>
      _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// A list of pages to be displayed in the onboarding tutorial.
  ///
  /// Each page is represented by a map containing a title, a description,
  /// and an icon.
  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'title': 'Welcome to Advisor Desk!',
      'description':
          'Your personal performance tracker. Monitor your calls, salary, and goals all in one place.',
      'image': Icons.waving_hand,
    },
    {
      'title': 'Personalize Your Profile',
      'description':
          'Tap on the profile icon on the dashboard to add your name and a profile picture.',
      'image': Icons.account_circle,
    },
    {
      'title': 'Your Dashboard at a Glance',
      'description':
          'The dashboard shows your monthly summary, including calls, login hours, salary, and more. Use the arrows to navigate between months.',
      'image': Icons.dashboard,
    },
    {
      'title': 'Customize Your Dashboard',
      'description':
          'Don\'t like the default dashboard layout? Go to `Settings -> Customize Dashboard` to reorder or hide sections to your liking.',
      'image': Icons.view_quilt,
    },
    {
      'title': 'Adding Your Entries',
      'description':
          'Tap the "+" button to add your daily work, non-billable calls, CSAT scores, and CQ scores.',
      'image': Icons.add_circle,
    },
    {
      'title': 'Set & Track Your Goals',
      'description':
          'Set monthly goals for calls, login hours, and salary to stay motivated. Track your progress on the dashboard.',
      'image': Icons.flag,
    },
    {
      'title': 'Detailed Reports',
      'description':
          'Dive deep into your performance with monthly reports. Export your data to PDF or Excel for your records.',
      'image': Icons.bar_chart,
    },
    {
      'title': 'Meet Your AI Assistant',
      'description':
          'Use Advisor Desk AI to get smart insights and analyze your performance data with the power of AI.',
      'image': Icons.auto_awesome,
    },
    {
      'title': 'Choose Your Look',
      'description':
          'Customize the app\'s appearance by choosing your favorite color theme from the settings.',
      'image': Icons.color_lens,
    },
    {
      'title': 'Accurate Salary Estimates',
      'description':
          'Get a clear estimate of your salary, including CSAT bonuses and TDS deductions.',
      'image': Icons.monetization_on,
    },
    {
      'title': 'We Value Your Feedback',
      'description':
          'Have a question or a suggestion? Visit the "About Developer" section in the settings to get in touch.',
      'image': Icons.feedback,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Advisor Desk Features'),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingPages.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _onboardingPages[index]['image'] as IconData,
                        size: 120,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        _onboardingPages[index]['title'] as String,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _onboardingPages[index]['description'] as String,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// Builds the page indicator dots at the bottom of the screen.
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingPages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 12,
          width: _currentPage == index ? 36 : 12,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  /// Builds the navigation buttons (Previous, Next, Finish) for the tutorial.
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            ElevatedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Previous', style: TextStyle(fontSize: 16)),
            ),
          const Spacer(),
          if (_currentPage < _onboardingPages.length - 1)
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Next', style: TextStyle(fontSize: 16)),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Finish', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
    );
  }
}
