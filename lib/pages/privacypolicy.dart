import 'dart:ui';
import 'package:flutter/material.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Glassmorphic container
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '''
Borla GH ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application ("App") and services.

1. Information We Collect
We may collect the following types of information:
• Personal Information: Name, phone number, email address, location (for pickup and delivery).
• Usage Data: App usage patterns, access times, and interactions with features.
• Device Information: Device type, operating system, and app version.
• Location Data: With your permission, we collect location data for accurate service delivery.

2. How We Use Your Information
We use your information to:
• Provide and improve our waste management services
• Process pickup, bin replacement, and recycling requests
• Communicate updates, confirmations, or changes to services
• Respond to customer service inquiries
• Analyze and enhance app performance

3. How We Share Your Information
We do not sell or rent your personal information. We may share your information only with:
• Service providers who support our operations (e.g., delivery/logistics partners)
• Authorities if required by law or to protect our legal rights

4. Data Security
We take reasonable measures to protect your data from loss, misuse, or unauthorized access. However, no system is 100% secure, and we cannot guarantee absolute security.

5. Your Rights
You have the right to:
• Access, update, or delete your personal information
• Opt-out of marketing communications
• Withdraw consent for location tracking
To exercise these rights, please contact us at: info@borlagh.com

6. Children's Privacy
Our services are not directed to children under 13. We do not knowingly collect data from minors.

7. Changes to This Policy
We may update this policy from time to time. We’ll notify users through the app or our website when major changes are made.

8. Contact Us
If you have any questions about this Privacy Policy, please contact us at:
Borla GH
Email: info@borlagh.com
Phone:
Website: www.borlagh.com/
                              ''',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
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
