import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
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
      'description': "This app helps you track your daily calls, login time, and salary. Let's get started!",
      'image': Icons.waving_hand,
    },
    {
      'title': 'Add Your Daily Entry',
      'description': 'Tap the "+" button on the dashboard. Enter your Date, Login Time (Hours, Minutes, Seconds), and Call Count. Then tap "Add Entry".',
      'image': Icons.add_circle_outline,
    },
    {
      'title': 'Add CSAT Entry',
      'description': 'In the "Add New Entry" screen, switch to the "CSAT Entry" tab. Enter the Date, CSAT Score, and any remarks. Tap "Add CSAT Entry".',
      'image': Icons.sentiment_satisfied_alt,
    },
    {
      'title': 'Add CQ Entry',
      'description': 'In the "Add New Entry" screen, switch to the "CQ Entry" tab. Enter the Audit Date and Call Quality Percentage. Tap "Add CQ Entry".',
      'image': Icons.assessment,
    },
    {
      'title': 'View Monthly Performance',
      'description': 'Swipe left/right on the dashboard or use the "Monthly" tab to see your monthly reports.',
      'image': Icons.bar_chart,
    },
    {
      'title': 'Export Reports',
      'description': 'Go to the "All Reports" section and tap "Export PDF" to save your reports.',
      'image': Icons.picture_as_pdf,
    },
    {
      'title': 'Export to Excel',
      'description': 'Now you can also export your monthly reports to Excel for more detailed analysis. Find this option in the "All Reports" section.',
      'image': Icons.table_chart,
    },
    {
      'title': 'Accurate Salary Estimate',
      'description': 'Your estimated salary now includes a CSAT bonus (if criteria met) and a 10% TDS deduction for a more accurate calculation.',
      'image': Icons.money,
    },
    {
      'title': 'Understand Salary Calculation',
      'description': 'Salary is calculated based on your call count and login time. Check the FAQ for details.',
      'image': Icons.calculate,
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
                  padding: const EdgeInsets.all(24.0), // Increased padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _onboardingPages[index]['image'] as IconData,
                        size: 120, // Increased icon size
                        color: AppColors.dishTvOrange,
                      ),
                      const SizedBox(height: 40), // Increased spacing
                      Text(
                        _onboardingPages[index]['title'] as String,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.dishTvOrange,
                            ), // Larger title
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20), // Increased spacing
                      Text(
                        _onboardingPages[index]['description'] as String,
                        style: Theme.of(context).textTheme.titleMedium, // Larger description
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
          const SizedBox(height: 30), // Increased bottom spacing
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
          height: 12, // Increased height
          width: _currentPage == index ? 36 : 12, // Increased width
          margin: const EdgeInsets.symmetric(horizontal: 6), // Increased margin
          decoration: BoxDecoration(
            color: _currentPage == index ? AppColors.dishTvOrange : Colors.grey.shade400, // Lighter grey for inactive
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0), // Increased padding
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
                backgroundColor: AppColors.dishTvOrange, // Orange button
                foregroundColor: Colors.white, // White text
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Larger padding
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
              ),
              child: const Text('Previous', style: TextStyle(fontSize: 16)), // Larger text
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
                backgroundColor: AppColors.dishTvOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Next', style: TextStyle(fontSize: 16)),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Or navigate to home screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dishTvOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Finish', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
    );
  }
}
