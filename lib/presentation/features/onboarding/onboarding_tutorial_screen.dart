import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';

class OnboardingTutorialScreen extends StatefulWidget {
  const OnboardingTutorialScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingTutorialScreen> createState() => _OnboardingTutorialScreenState();
}

class _OnboardingTutorialScreenState extends State<OnboardingTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingPages = [
    {
      'title': 'Welcome to Advisor Desk!',
      'description': 'Your personal performance tracker. Monitor your calls, salary, and goals all in one place.',
      'image': Icons.waving_hand,
    },
    {
      'title': 'Personalize Your Profile',
      'description': 'Tap on the profile icon on the dashboard to add your name and a profile picture.',
      'image': Icons.account_circle,
    },
    {
      'title': 'Your Dashboard at a Glance',
      'description': 'The dashboard shows your monthly summary, including calls, login hours, salary, and more. Use the arrows to navigate between months.',
      'image': Icons.dashboard,
    },
    {
      'title': 'Customize Your Dashboard',
      'description': 'Don\'t like the default dashboard layout? Go to `Settings -> Customize Dashboard` to reorder or hide sections to your liking.',
      'image': Icons.view_quilt,
    },
    {
      'title': 'Adding Your Entries',
      'description': 'Tap the "+" button to add your daily work, non-billable calls, CSAT scores, and CQ scores.',
      'image': Icons.add_circle,
    },
    {
      'title': 'Set & Track Your Goals',
      'description': 'Set monthly goals for calls, login hours, and salary to stay motivated. Track your progress on the dashboard.',
      'image': Icons.flag,
    },
    {
      'title': 'Detailed Reports',
      'description': 'Dive deep into your performance with monthly reports. Export your data to PDF or Excel for your records.',
      'image': Icons.bar_chart,
    },
    {
      'title': 'Meet Your AI Assistant',
      'description': 'Use Advisor Desk AI to get smart insights and analyze your performance data with the power of AI.',
      'image': Icons.auto_awesome,
    },
    {
      'title': 'Choose Your Look',
      'description': 'Customize the app\'s appearance by choosing your favorite color theme from the settings.',
      'image': Icons.color_lens,
    },
    {
      'title': 'Accurate Salary Estimates',
      'description': 'Get a clear estimate of your salary, including CSAT bonuses and TDS deductions.',
      'image': Icons.monetization_on,
    },
    {
      'title': 'We Value Your Feedback',
      'description': 'Have a question or a suggestion? Visit the "About Developer" section in the settings to get in touch.',
      'image': Icons.feedback,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Features Tour'),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _onboardingPages.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return _buildOnboardingPage(context, _onboardingPages[index]);
              },
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['image'] as IconData,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            data['title'] as String,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            data['description'] as String,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const SizedBox(width: 48), // Spacer to balance layout
              
              if (_currentPage < _onboardingPages.length - 1)
                SizedBox(
                  width: 140,
                  child: AnimatedButton(
                     onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    child: Row(
                       mainAxisSize: MainAxisSize.min,
                      children: const [
                         Text('Next'),
                         SizedBox(width: 8),
                         Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                )
              else
                 SizedBox(
                   width: 140,
                   child: AnimatedButton(
                     onPressed: () {
                      Navigator.pop(context);
                    },
                     child: const Text('Get Started'),
                  ),
                 ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingPages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          width: _currentPage == index ? 24 : 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentPage == index 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
