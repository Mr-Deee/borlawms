import 'dart:ui';
import 'package:flutter/material.dart';

class Privacypolicy extends StatefulWidget {
  const Privacypolicy({super.key});

  @override
  State<Privacypolicy> createState() => _PrivacypolicyState();
}

class _PrivacypolicyState extends State<Privacypolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image or Gradient
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/BG.jpg"),
                // Add your image to assets
                fit: BoxFit.cover,
              ),
              // Or replace with gradient:
              // gradient: LinearGradient(
              //   colors: [Colors.green, Colors.blue],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
          ),
          // Glass Effect
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 19, sigmaY: 15),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Privacy Policy',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Borla GH ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application ("App") and services.',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        _SectionTitle('1. Information We Collect'),
                        _BulletPoint(
                            'Personal Information: Name, phone number, email address, location (for pickup and delivery).'),
                        _BulletPoint(
                            'Usage Data: App usage patterns, access times, and interactions with features.'),
                        _BulletPoint(
                            'Device Information: Device type, operating system, and app version.'),
                        _BulletPoint(
                            'Location Data: With your permission, we collect location data for accurate service delivery.'),
                        SizedBox(height: 20),
                        _SectionTitle('2. How We Use Your Information'),
                        _BulletPoint(
                            'Provide and improve our waste management services.'),
                        _BulletPoint(
                            'Process pickup, bin replacement, and recycling requests.'),
                        _BulletPoint(
                            'Communicate updates, confirmations, or changes to services.'),
                        _BulletPoint('Respond to customer service inquiries.'),
                        _BulletPoint('Analyze and enhance app performance.'),
                        SizedBox(height: 20),
                        _SectionTitle('3. How We Share Your Information'),
                        _BulletPoint(
                            'We do not sell or rent your personal information.'),
                        _BulletPoint(
                            'We may share your information only with:\n• Service providers who support our operations (e.g., delivery/logistics partners)\n• Authorities if required by law or to protect our legal rights'),
                        SizedBox(height: 20),
                        _SectionTitle('4. Data Security'),
                        Text(
                          'We take reasonable measures to protect your data from loss, misuse, or unauthorized access. However, no system is 100% secure, and we cannot guarantee absolute security.',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        _SectionTitle('5. Your Rights'),
                        _BulletPoint(
                            'Access, update, or delete your personal information.'),
                        _BulletPoint('Opt-out of marketing communications.'),
                        _BulletPoint('Withdraw consent for location tracking.'),
                        Text(
                          '\nTo exercise these rights, please contact us at: info@borlagh.com',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        _SectionTitle('6. Children\'s Privacy'),
                        Text(
                          'Our services are not directed to children under 13. We do not knowingly collect data from minors.',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        _SectionTitle('7. Changes to This Policy'),
                        Text(
                          'We may update this policy from time to time. We’ll notify users through the app or our website when major changes are made.',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 20),
                        _SectionTitle('8. Contact Us'),
                        Text(
                          'If you have any questions about this Privacy Policy, please contact us at:\n\n'
                          'Borla GH\n'
                          'Email: info@borlagh.com\n'
                          'Phone: \n'
                          'Website: www.borlagh.com/',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16, color: Colors.white)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 16, color: Colors.white))),
        ],
      ),
    );
  }
}
