import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/PrivacyPolicy.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
  Color _cardColor = Colors.green.shade800.withOpacity(0.1);

  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  void _onCardTap() {
    setState(() {
      _cardColor = _cardColor == Colors.green.shade800
          ? Colors.green.shade600
          : Colors.green.shade800;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg4.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.green.withOpacity(0.3),
                  BlendMode.overlay,
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 60.0, left: 16, right: 16, bottom: 24),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Text('Version 1.0.9',
                      style: TextStyle(fontSize: 14, color: Colors.white70)),
                  SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: _onCardTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cardColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Borla GH – Waste Pickup & Disposal',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Borla GH provides reliable waste management services in Ghana for both homes and businesses...',
                                  style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'WHY CHOOSE BORLA GH',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                _bullet('Easy Waste Pickup Requests: Schedule pickups anytime.'),
                                _bullet('Track Pickup Status: Real-time updates.'),
                                _bullet('Request Bin Replacements: Get a new bin via the app.'),
                                _bullet('Eco-Friendly Recycling Options: Support a clean environment.'),
                                _bullet('Reliable Service: No stress, no calls.'),
                                SizedBox(height: 12),
                                Text(
                                  'HOW TO MAKE A BORLA PICKUP',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                _step('Download and install BorlaGh from Google Play Store.'),
                                _step('Open the app.'),
                                _step('Login with your username & password.'),
                                _step('Your current location loads in the background.'),
                                _step('Choose your bin size.'),
                                _step('Request for a waste service.'),
                                SizedBox(height: 12),
                                Text(
                                  'HOW TO SCHEDULE A BORLA PICKUP',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                _step('Login with your username & password.'),
                                _step('Navigate to My Schedules.'),
                                _step('Select a pickup date and time.'),
                                _step('Schedule Pickup.'),
                                SizedBox(height: 16),
                                Text(
                                  'CONTACT INFORMATION',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                _infoText('Website: www.borlagh.com'),
                                _infoText('Email: info@borlagh.com'),
                                _infoText('Contact: +233'),
                                SizedBox(height: 8),
                                Text(
                                  'Terms & Conditions',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                _infoText('We prioritize your privacy...'),
                                _infoText('https://www.borlagh.com/terms'),
                                _infoText('https://www.borlagh.com/privacy'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Divider(
                    thickness: 2,
                    color: Colors.white70,
                    indent: 60,
                    endIndent: 60,
                  ),
                  SizedBox(height: 16),
                  _infoTile(
                    icon: Icons.privacy_tip_rounded,
                    label: "Privacy Policy",
                    onTap: () => _showPrivacyDialog(context),
                  ),
                  SizedBox(height: 12),
                  _infoTile(
                    icon: Icons.description_rounded,
                    label: "Terms and Conditions",
                    onTap: () => _showTermsDialog(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ", style: TextStyle(fontSize: 14, color: Colors.white)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.white70))),
      ],
    ),
  );

  Widget _step(String text) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 4),
    child: Row(
      children: [
        Icon(Icons.check_circle, size: 16, color: Colors.white),
        SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.white))),
      ],
    ),
  );

  Widget _infoText(String text) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 4),
    child: Text(text, style: TextStyle(fontSize: 14, color: Colors.white70)),
  );

  Widget _infoTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade800.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white60),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Privacypolicy()),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _buildDialog(
        title: "Terms and Conditions",
        content: "By using this app, you agree to abide by the rules...",
      ),
    );
  }

  Widget _buildDialog({required String title, required String content}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.green.shade800,
      title: Text(title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      content: Text(
        content,
        style: TextStyle(fontSize: 15, color: Colors.white70),
      ),
      actions: [
        TextButton(
          child: Text("Close", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
