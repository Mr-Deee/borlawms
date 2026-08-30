import 'dart:ui';
import 'package:borlawms/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  bool onLastPage = false;
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      backgroundImage: 'assets/images/onb.jpg',
      title: "Welcome to Borla",
      subtitle: "Smart Waste Management",
      body: "Trash the Waste, Not the Planet! Join our waste management campaign to reduce, reuse, and recycle for a cleaner, greener future.",
      image: 'assets/images/bwmslogo.png',
      titleColor: Colors.white,
      subtitleColor: Color(0xFF19AF5F),
      bodyColor: Colors.white70,
      gradientColors: [Color(0xFF19AF5F), Color(0xFF0D7C3F)],
    ),
    OnboardingData(
      backgroundImage: 'assets/images/signonb1.jpg',
      title: "Create Your Account",
      subtitle: "Get Started in Minutes",
      body: "Tap 'New User? Sign up' to create your account. Fill in your details and start managing waste efficiently.",
      image: 'assets/images/signup.png',
      titleColor: Colors.white,
      subtitleColor: Color(0xFFFFA726),
      bodyColor: Colors.white70,
      gradientColors: [Color(0xFFFFA726), Color(0xFFF57C00)],
    ),
    OnboardingData(
      backgroundImage: 'assets/images/signonb1.jpg',
      title: "Sign In Securely",
      subtitle: "Access Your Dashboard",
      body: "Enter your registered email and password to access your personalized waste management dashboard.",
      image: 'assets/images/signin.png',
      titleColor: Colors.white,
      subtitleColor: Color(0xFF42A5F5),
      bodyColor: Colors.white70,
      gradientColors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
    ),
    OnboardingData(
      backgroundImage: 'assets/images/onb21.jpg',
      title: "Go Online",
      subtitle: "Receive Requests Instantly",
      body: "Toggle to go online and start receiving waste collection requests from customers in real-time.",
      image: 'assets/images/toggle.png',
      titleColor: Colors.white,
      subtitleColor: Color(0xFF19AF5F),
      bodyColor: Colors.white70,
      gradientColors: [Color(0xFF19AF5F), Color(0xFF0D7C3F)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                onLastPage = (index == _onboardingData.length - 1);
              });
              _animationController.reset();
              _animationController.forward();
            },
            children: _onboardingData.map((data) {
              return _buildPage(data);
            }).toList(),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Dot Indicator
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _onboardingData.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 12,
                      expansionFactor: 3,
                      dotColor: Colors.white.withOpacity(0.3),
                      activeDotColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Skip Button (only show on first pages)
                      if (!onLastPage)
                        Expanded(
                          flex: 2,
                          child: TextButton(
                            onPressed: () => _navigateToSignIn(),
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      // Next/Get Started Button
                      Expanded(
                        flex: onLastPage ? 1 : 3,
                        child: _buildActionButton(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(data.backgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Decoration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    "Step ${_currentPage + 1} of ${_onboardingData.length}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Image
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: 180,
                    width: 180,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          data.gradientColors[0].withOpacity(0.2),
                          data.gradientColors[1].withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      data.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: data.titleColor,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.subtitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: data.subtitleColor,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Body Text
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      data.body,
                      style: TextStyle(
                        fontSize: 15,
                        color: data.bodyColor,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (onLastPage) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF19AF5F), Color(0xFF0D7C3F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF19AF5F).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _navigateToSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: _nextPage,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Next",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: Colors.white.withOpacity(0.9),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void _navigateToSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignIn()),
    );
  }
}

class OnboardingData {
  final String backgroundImage;
  final String title;
  final String subtitle;
  final String body;
  final String image;
  final Color titleColor;
  final Color subtitleColor;
  final Color bodyColor;
  final List<Color> gradientColors;

  OnboardingData({
    required this.backgroundImage,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.image,
    required this.titleColor,
    required this.subtitleColor,
    required this.bodyColor,
    required this.gradientColors,
  });
}