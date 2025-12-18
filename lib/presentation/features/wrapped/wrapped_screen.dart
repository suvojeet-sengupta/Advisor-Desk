import 'dart:io';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/wrapped_stats.dart';
import 'package:advisor_desk/domain/services/wrapped_service.dart';
import 'package:advisor_desk/core/constants/app_colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class WrappedScreen extends StatefulWidget {
  final MonthlySummary summary;

  const WrappedScreen({Key? key, required this.summary}) : super(key: key);

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen> {
  late WrappedStats stats;
  final PageController _pageController = PageController();
  final ScreenshotController _screenshotController = ScreenshotController();
  late ConfettiController _confettiController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    stats = WrappedService().generateStats(widget.summary);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    if (index == 5) { // Persona/Earnings slide usually calls for celebration
       _confettiController.play();
    }
  }

  Future<void> _shareWrappedCard() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final file = await File('${directory.path}/advisor_wrapped.png').create();
      await file.writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)], text: 'Check out my Advisor Wrapped for ${stats.monthName}!');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dark theme for that "Spotify Wrapped" vibe
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1DB954), // Spotify Green-ish
          secondary: Color(0xFF9147FF), // Purple
          tertiary: Color(0xFFFF0055), // Pink
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Gradient (changes based on page)
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(_currentPage),
                ),
              ),
            ),
            
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildIntroSlide(),
                _buildVolumeSlide(),
                _buildBestDaySlide(),
                _buildQualitySlide(),
                _buildEarningsSlide(),
                _buildPersonaSlide(),
                _buildSummarySlide(), // The Shareable Card
              ],
            ),

            // Navigation Indicators
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(_currentPage == index ? 1 : 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),

            // Confetti Overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
              ),
            ),

            // Close Button
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(int page) {
    switch (page) {
      case 0: return [const Color(0xFF2E0249), const Color(0xFF570A57)]; // Deep Purple
      case 1: return [const Color(0xFF0F3460), const Color(0xFF533483)]; // Blue/Indigo
      case 2: return [const Color(0xFFA91079), const Color(0xFF2E0249)]; // Pink/Purple
      case 3: return [const Color(0xFF006E7F), const Color(0xFFEE5007)]; // Teal/Orange
      case 4: return [const Color(0xFF166d3b), const Color(0xFF000000)]; // Green/Black (Money)
      case 5: return [const Color(0xFFF9D923), const Color(0xFF187498)]; // Gold/Blue
      default: return [const Color(0xFF000000), const Color(0xFF434343)]; // Black/Grey
    }
  }

  // ---

  Widget _buildIntroSlide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ZoomIn(child: const Icon(Icons.auto_awesome, size: 80, color: Colors.white)),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              '${stats.monthName} ${stats.year}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: const Text(
              'Wrapped',
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1500),
            child: const Text(
              "You made some waves this month...",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlide() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(
            child: const Text(
              "The Hustle",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 40, color: Colors.white, height: 1.2),
                children: [
                  const TextSpan(text: "You spent\n"),
                  TextSpan(
                    text: "${stats.totalHours.toStringAsFixed(1)} hours",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1DB954)),
                  ),
                  const TextSpan(text: "online..."),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 40, color: Colors.white, height: 1.2),
                children: [
                  const TextSpan(text: "And connected with\n"),
                  TextSpan(
                    text: "${stats.totalCalls} customers",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9147FF)),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestDaySlide() {
    if (stats.bestDayDate == null) return const SizedBox();
    
    final dateStr = DateFormat('MMMM d').format(stats.bestDayDate!);
    
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BounceInDown(
            child: const Icon(Icons.emoji_events_rounded, size: 100, color: Colors.amber),
          ),
          const SizedBox(height: 40),
          FadeIn(
            delay: const Duration(milliseconds: 500),
            child: const Text(
              "Your Peak Performance",
              style: TextStyle(fontSize: 24, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: Text(
              dateStr,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1200),
            child: Text(
              "On this day, you were unstoppable with ${stats.bestDayCalls} calls!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySlide() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElasticIn(child: const Icon(Icons.star, color: Colors.yellow, size: 40)),
              const SizedBox(width: 10),
              ElasticIn(delay: const Duration(milliseconds: 100), child: const Icon(Icons.star, color: Colors.yellow, size: 50)),
              const SizedBox(width: 10),
              ElasticIn(delay: const Duration(milliseconds: 200), child: const Icon(Icons.star, color: Colors.yellow, size: 40)),
            ],
          ),
          const SizedBox(height: 40),
          FadeInUp(
            child: Text(
              "${stats.averageCsat.toStringAsFixed(1)}% CSAT",
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
           const SizedBox(height: 10),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: Text(
              "${stats.averageCq.toStringAsFixed(1)}% CQ",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: const Text(
              "Quality is your habit, not an act.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSlide() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinPerfect(
            child: const Icon(Icons.monetization_on_rounded, size: 100, color: Colors.greenAccent),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            child: const Text(
              "The Reward",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              currencyFormat.format(stats.totalEarnings),
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: const Text(
              "Your estimated net salary.",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaSlide() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: const Text(
              "You are...",
              style: TextStyle(fontSize: 24, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 40),
          ZoomIn(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                stats.advisorPersona.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              stats.personaDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySlide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Screenshot(
            controller: _screenshotController,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E0249), Color(0xFFA91079)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "ADVISOR WRAPPED",
                    style: TextStyle(fontSize: 14, letterSpacing: 2, color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 24),
                  _buildStatRow("Calls", stats.totalCalls.toString()),
                  _buildStatRow("Hours", "${stats.totalHours.toStringAsFixed(1)}h"),
                  _buildStatRow("CSAT", "${stats.averageCsat.toStringAsFixed(1)}%"),
                  const Divider(color: Colors.white30, height: 32),
                  Text(
                    stats.advisorPersona,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _shareWrappedCard,
            icon: const Icon(Icons.share),
            label: const Text("Share This"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
