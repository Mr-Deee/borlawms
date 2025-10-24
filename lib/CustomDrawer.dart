import 'package:borlawms/pages/Aboutpage.dart';
import 'package:borlawms/pages/Profilepage.dart';
import 'package:borlawms/pages/Requests.dart';
import 'package:borlawms/pages/Subscriptions.dart';
import 'package:borlawms/widgets/Schedules.dart';
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
  @override
  void initState() {
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
    final lastname = Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
    final phoneNumber = Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9FC), Color(0xFFE8ECEF)],
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
                  )
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
                            FontAwesomeIcons.rightFromBracket,
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
              context,
              icon: FontAwesomeIcons.clipboardList, // My Requests
              title: "My Requests",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Requestpage())),
            ),
            _buildDrawerTile(
              context,
              icon: FontAwesomeIcons.idCardClip, // Profile
              title: "Profile",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
            _buildDrawerTile(
              context,
              icon: FontAwesomeIcons.clockRotateLeft, // Request History
              title: "Request History",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Requestpage())),
            ),
            _buildDrawerTile(
              context,
              icon: FontAwesomeIcons.calendarDays, // Schedules & Subscriptions
              title: "Schedules & Subscriptions",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionAndSchedulePage())),
            ),
            _buildDrawerTile(
              context,
              icon: FontAwesomeIcons.circleQuestion, // About
              title: "About",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AboutPage())),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Divider(thickness: 1.2),
            ),

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

  Widget _buildDrawerTile(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF28A745), Color(0xFF2ECC71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(icon, color: Colors.white, size: 18),
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
              const FaIcon(FontAwesomeIcons.angleRight, size: 14, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, "/SignIn", (_) => false);
            },
            child: const Text("Yes", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
