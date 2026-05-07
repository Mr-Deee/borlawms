import 'dart:ui';
import 'package:shimmer/shimmer.dart';
import 'package:borlawms/pages/Aboutpage.dart';
import 'package:borlawms/pages/Profilepage.dart';
import 'package:borlawms/pages/Requests.dart';
import 'package:borlawms/widgets/Subscriptions&Schedules.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'Assistant/assistantmethods.dart';
import 'Model/WMSDB.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    if (mounted && !_isDisposed) {
      AssistantMethod.getCurrentOnlineUserInfo(context);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || _isDisposed) return Container();

    final username = Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
    final lastname = Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
    final phoneNumber = Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F7FB), Color(0xFFE9EDF0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/wms.png', height: 40),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "$username $lastname",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _confirmLogout(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDrawerTile(
              icon: FontAwesomeIcons.clipboardList,
              title: "My Requests",
              color: const Color(0xFF2ECC71),
              onTap: () {
                if (!mounted || _isDisposed) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Requestpage()));
              },
            ),
            _buildDrawerTile(
              icon: FontAwesomeIcons.idCard,
              title: "Profile",
              color: const Color(0xFF27AE60),
              onTap: () {
                if (!mounted || _isDisposed) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              },
            ),
            _buildDrawerTile(
              icon: FontAwesomeIcons.clockRotateLeft,
              title: "Request History",
              color: const Color(0xFF16A085),
              onTap: () {
                if (!mounted || _isDisposed) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Requestpage()));
              },
            ),
            _buildDrawerTile(
              icon: FontAwesomeIcons.calendarDays,
              title: "Schedules & Subscriptions",
              color: const Color(0xFF2980B9),
              onTap: () {
                if (!mounted || _isDisposed) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionAndSchedulePage()));
              },
            ),
            _buildDrawerTile(
              icon: FontAwesomeIcons.circleQuestion,
              title: "About",
              color: const Color(0xFFF39C12),
              onTap: () {
                if (!mounted || _isDisposed) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) =>  AboutPage()));
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Divider(thickness: 1.2),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LiquidSignatureText(
                  text: "By DANIEL NARTERH",
                  gradientColors: [
                    Color(0x5282B1FF),
                    Color(0xFFEEF7FA),
                    Color(0xFFEEF7FA),
                  ],
                  baseOpacity: 0.3,
                  blurIntensity: 8,
                  width: 280,
                ),
                const SizedBox(height: 8),
                LiquidSignatureText(
                  text: "Mlabstech",
                  gradientColors: [
                    Color(0x40404),
                    Color(0xFFEEF7FA),
                    Color(0xFFEEF7FA),
                  ],
                  baseOpacity: 0.35,
                  blurIntensity: 10,
                  width: 220,
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "BorlaGh v1.1",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.angleRight,
                size: 14,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    if (!mounted || _isDisposed) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              if (!mounted || _isDisposed) return;
              FirebaseAuth.instance.signOut();
              if (mounted && !_isDisposed) {
                Navigator.pushNamedAndRemoveUntil(context, "/SignIn", (_) => false);
              }
            },
            child: const Text("Yes", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              if (mounted && !_isDisposed) Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}

class LiquidSignatureText extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final double baseOpacity;
  final double blurIntensity;
  final double width;
  final double fontSize;

  const LiquidSignatureText({
    super.key,
    required this.text,
    required this.gradientColors,
    this.baseOpacity = 0.3,
    this.blurIntensity = 4,
    this.width = 250,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shaderWidth = constraints.maxWidth > 0 ? constraints.maxWidth : width;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.9,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: gradientColors.map((c) => c.withOpacity(0.8)).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, shaderWidth, 100)),
                  shadows: [
                    Shadow(
                      color: gradientColors.first.withOpacity(0.6),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              Shimmer.fromColors(
                baseColor: gradientColors.last.withOpacity(baseOpacity),
                highlightColor: gradientColors.first.withOpacity(0.9),
                period: const Duration(seconds: 3),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(Rect.fromLTWH(0, 0, shaderWidth, 100)),
                  ),
                ),
              ),
              Positioned(
                bottom: -5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurIntensity,
                      sigmaY: blurIntensity,
                    ),
                    child: Container(
                      width: shaderWidth * 0.9,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}