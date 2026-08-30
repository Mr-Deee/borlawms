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

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  bool _isDisposed = false;
  String username = "";
  String lastname = "";
  String phoneNumber = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _loadUserData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted || _isDisposed) return;

    try {
      await AssistantMethod.getCurrentOnlineUserInfo(context);

      if (!mounted || _isDisposed) return;

      final wmsProvider = Provider.of<WMS>(context, listen: false);
      setState(() {
        username = wmsProvider.riderInfo?.firstname ?? "";
        lastname = wmsProvider.riderInfo?.lastname ?? "";
        phoneNumber = wmsProvider.riderInfo?.phone ?? "";
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || _isDisposed) return Container();

    if (!_isLoading) {
      try {
        final wmsProvider = Provider.of<WMS>(context, listen: false);
        if (username.isEmpty && wmsProvider.riderInfo != null) {
          username = wmsProvider.riderInfo?.firstname ?? "";
          lastname = wmsProvider.riderInfo?.lastname ?? "";
          phoneNumber = wmsProvider.riderInfo?.phone ?? "";
        }
      } catch (e) {
        print("Error accessing provider: $e");
      }
    }

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
            // Header
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
                        child: _isLoading
                            ? Container(
                          height: 24,
                          width: 150,
                          color: Colors.grey[300],
                        )
                            : Text(
                          "$username $lastname".trim(),
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
                            FontAwesomeIcons.rightFromBracket,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _isLoading
                      ? Container(
                    height: 16,
                    width: 120,
                    color: Colors.grey[300],
                  )
                      : Text(
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

            // Menu Items - Using Material Icons
            _buildDrawerTile(
              icon: Icons.request_quote_sharp,
              title: "My Requests",
              color: const Color(0xFF2ECC71),
              onTap: () => _navigateToPage(context, const Requestpage()),
            ),
            _buildDrawerTile(
              icon: Icons.supervised_user_circle,
              title: "Profile",
              color: const Color(0xFF27AE60),
              onTap: () => _navigateToPage(context, const ProfilePage()),
            ),
            _buildDrawerTile(
              icon: Icons.history,
              title: "Request History",
              color: const Color(0xFF16A085),
              onTap: () => _navigateToPage(context, const Requestpage()),
            ),
            _buildDrawerTile(
              icon: Icons.schedule_rounded,
              title: "Schedules & Subscriptions",
              color: const Color(0xFF2980B9),
              onTap: () => _navigateToPage(context, const SubscriptionAndSchedulePage()),
            ),
            _buildDrawerTile(
              icon: Icons.question_answer_sharp,
              title: "About",
              color: const Color(0xFFF39C12),
              onTap: () => _navigateToPage(context,  AboutPage()),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Divider(thickness: 1.2),
            ),

            // Footer - Imprint Style
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Decorative line
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF19AF5F), Color(0xFF0D7C3F)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Main imprint text
                  const Text(
                    "Built by",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Developer name with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF19AF5F), Color(0xFF0D7C3F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      "DANIEL NARTERH",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),


                  // Divider with dots
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                        ),
                      ),

                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),


                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    if (!mounted || _isDisposed) return;
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && !_isDisposed) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      }
    });
  }

  // ✅ FIXED: Use Icon widget instead of FaIcon for Material Icons
  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
    bool isActive = false,
    bool isDanger = false,
    String? badge,
    double? iconSize,
    EdgeInsetsGeometry? padding,
  }) {
    final Color iconColor = isDanger ? Colors.red.shade700 : color;
    final Color textColor = isDanger ? Colors.red.shade700 : Colors.black87;
    final Color bgColor = isDanger ? Colors.red.shade50 : Colors.white;
    final Color borderColor = isDanger ? Colors.red.shade200 : Colors.grey.shade100;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: iconColor.withOpacity(0.1),
          highlightColor: iconColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isActive ? iconColor.withOpacity(0.08) : bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? iconColor.withOpacity(0.3) : borderColor,
                width: isActive ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                if (isActive)
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                // Icon Container with Gradient
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withOpacity(0.25),
                        iconColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // ✅ FIX: Use Icon widget for Material Icons
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: iconSize ?? 18,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Badge, Trailing, or Arrow
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade500,
                          Colors.red.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else if (trailing != null)
                  trailing
                else if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            iconColor.withOpacity(0.15),
                            iconColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: iconColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Active",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: iconColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                  // ✅ FIX: Use Material Icon for arrow
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    if (!mounted || _isDisposed) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Sign Out",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to sign out?",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted && !_isDisposed) Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (mounted && !_isDisposed) {
                Navigator.pop(dialogContext);
              }
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted && !_isDisposed) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/SignIn",
                        (route) => false,
                  );
                }
              } catch (e) {
                print("Error signing out: $e");
                if (mounted && !_isDisposed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error signing out: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text(
              "Sign Out",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
                          colors: gradientColors,
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