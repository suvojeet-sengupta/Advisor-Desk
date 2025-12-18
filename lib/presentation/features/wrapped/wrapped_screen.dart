import 'dart:io';
import 'dart:math';
import 'package:advisor_desk/domain/entities/monthly_summary.dart';
import 'package:advisor_desk/domain/entities/wrapped_stats.dart';
import 'package:advisor_desk/domain/services/wrapped_service.dart';
import 'package:advisor_desk/presentation/features/wrapped/widgets/wrapped_background.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
    if (index == 5) { // Persona slide
       _confettiController.play();
    }
  }

  Future<void> _shareWrappedCard() async {
    final image = await _screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final file = await File('${directory.path}/advisor_wrapped_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(image);
      await Share.shareXFiles([XFile(file.path)], text: 'Check out my Advisor Wrapped for ${stats.monthName}!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Animated Background
            WrappedBackground(pageIndex: _currentPage),
            
            // Content
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
                _buildSummarySlide(),
              ],
            ),

            // Navigation Indicators
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 30 : 8,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(_currentPage == index ? 1 : 0.3),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: _currentPage == index ? [
                        BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)
                      ] : [],
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
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Slides ---

  Widget _buildIntroSlide() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ZoomIn(child: const Icon(Icons.auto_awesome, size: 100, color: Colors.amberAccent)),
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              stats.monthName.toUpperCase(),
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white70),
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: Text(
              'WRAPPED',
              style: GoogleFonts.poppins(
                fontSize: 64, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
                shadows: [Shadow(color: Colors.purpleAccent, blurRadius: 20, offset: Offset(0,0))]
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Let's rewind your performance.",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlide() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(
            child: Text(
              "The Hustle",
              style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 50),
          
          // Hours Circular Indicator
          Center(
            child: CircularPercentIndicator(
              radius: 90.0,
              lineWidth: 15.0,
              percent: min(stats.totalHours / 200, 1.0), // Assuming 200h is "max" for visual
              animation: true,
              animationDuration: 1500,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stats.totalHours.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0, color: Colors.white),
                  ),
                  const Text("Hours", style: TextStyle(color: Colors.white70)),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.white24,
              progressColor: const Color(0xFF1DB954),
            ),
          ),
          
          const SizedBox(height: 50),
          
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                   const Icon(Icons.phone_in_talk, color: Color(0xFF9147FF), size: 40),
                   const SizedBox(width: 20),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         "${stats.totalCalls}",
                         style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                       ),
                       const Text("Calls Answered", style: TextStyle(color: Colors.white70)),
                     ],
                   )
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
    
    final dayFormat = DateFormat('d');
    final monthFormat = DateFormat('MMM');
    final weekdayFormat = DateFormat('EEEE');
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
          ),
          const SizedBox(height: 20),
          FadeIn(
            delay: const Duration(milliseconds: 500),
            child: Text(
              "Your Peak Day",
              style: GoogleFonts.poppins(fontSize: 24, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 40),
          
          // Calendar Widget
          ZoomIn(
            delay: const Duration(milliseconds: 800),
            child: Container(
              width: 200,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      monthFormat.format(stats.bestDayDate!).toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayFormat.format(stats.bestDayDate!),
                          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.black87, height: 1),
                        ),
                        Text(
                          weekdayFormat.format(stats.bestDayDate!),
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          FadeInUp(
            delay: const Duration(milliseconds: 1200),
            child: Text(
              "${stats.bestDayCalls} calls handled!",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySlide() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => 
              ElasticIn(
                delay: Duration(milliseconds: index * 200),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.star_rounded, color: Colors.amber, size: index == 1 ? 80 : 60),
                )
              )
            ),
          ),
          const SizedBox(height: 50),
          
          // CSAT Bar
          FadeInUp(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("CSAT Score", style: TextStyle(fontSize: 18, color: Colors.white70)),
                    Text("${stats.averageCsat.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 20.0,
                  percent: stats.averageCsat / 100,
                  animation: true,
                  animationDuration: 1200,
                  barRadius: const Radius.circular(10),
                  progressColor: Colors.blueAccent,
                  backgroundColor: Colors.white24,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // CQ Bar
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("CQ Score", style: TextStyle(fontSize: 18, color: Colors.white70)),
                    Text("${stats.averageCq.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  lineHeight: 20.0,
                  percent: stats.averageCq / 100,
                  animation: true,
                  animationDuration: 1200,
                  barRadius: const Radius.circular(10),
                  progressColor: Colors.purpleAccent,
                  backgroundColor: Colors.white24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSlide() {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinPerfect(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.greenAccent, width: 4),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 20)],
              ),
              child: const Icon(Icons.attach_money_rounded, size: 80, color: Colors.greenAccent),
            ),
          ),
          const SizedBox(height: 50),
          FadeInUp(
            child: const Text(
              "ESTIMATED EARNINGS",
              style: TextStyle(fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 500),
            child: Text(
              currencyFormat.format(stats.totalEarnings),
              style: GoogleFonts.spaceMono(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          FadeInUp(
            delay: const Duration(milliseconds: 1000),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Great work this month!",
                style: TextStyle(fontSize: 16, color: Colors.greenAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaSlide() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: const Text(
              "Your Advisor Persona",
              style: TextStyle(fontSize: 20, color: Colors.white70, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          
          // Persona Card
          ZoomIn(
            delay: const Duration(milliseconds: 300),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF4A00E0).withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10)),
                ],
                border: Border.all(color: Colors.white30),
              ),
              child: Column(
                children: [
                  const Icon(Icons.psychology_rounded, size: 80, color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    stats.advisorPersona.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 2, width: 50, color: Colors.white30),
                  const SizedBox(height: 20),
                  Text(
                    stats.personaDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySlide() {
    return Center(
      child: SingleChildScrollView( // Added for safety on smaller screens
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: 320,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF141E30), Color(0xFF243B55)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Card Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ADVISOR WRAPPED", style: GoogleFonts.oswald(color: Colors.white70, letterSpacing: 1.5, fontSize: 14)),
                              Text(stats.monthName.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Icon(Icons.auto_awesome, color: Colors.amber, size: 30),
                        ],
                      ),
                    ),
                    
                    // Card Body
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildStatRow("Total Hours", "${stats.totalHours.toStringAsFixed(1)}h"),
                          _buildStatRow("Calls Handled", "${stats.totalCalls}"),
                          _buildStatRow("CSAT Score", "${stats.averageCsat.toStringAsFixed(1)}%"),
                          _buildStatRow("Quality Score", "${stats.averageCq.toStringAsFixed(1)}%"),
                          const Divider(color: Colors.white24, height: 32),
                          Text(
                            stats.advisorPersona,
                            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Advisor Desk App",
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            AnimatedButton(
              onPressed: _shareWrappedCard,
              text: "Share with Friends",
            ),
          ],
        ),
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
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Simple Animated Button Helper
class AnimatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedButton({Key? key, required this.onPressed, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BounceInUp(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          shadowColor: Colors.white.withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.share_rounded),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
