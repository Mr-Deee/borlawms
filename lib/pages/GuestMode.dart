import 'dart:ui';

import 'package:borlawms/pages/RecyclePage.dart';
import 'package:borlawms/pages/addwmsdetails.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:borlawms/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Aboutpage.dart';

class GuestModeScreen extends StatefulWidget {
  @override
  _GuestModeScreenState createState() => _GuestModeScreenState();
}

class _GuestModeScreenState extends State<GuestModeScreen> {
  final DatabaseReference _binsale = FirebaseDatabase.instance.ref().child('WMS');
  final DatabaseReference _RECYCLE = FirebaseDatabase.instance.ref().child('WMS');

  List<Map<String, dynamic>> binsale = [];
  Map<dynamic, dynamic>? riderData;
  bool isRiderLoading = true;
  bool riderExists = false;
  List<Map<String, dynamic>> RECYCLERS =[];

  void _showCylindersDialog() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.recycling, color: Colors.green),
              SizedBox(width: 10),
              Text("Available Recyclers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: RECYCLERS.length,

              itemBuilder: (context, index) {
                final recyc = RECYCLERS[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(
                      Icons.recycling,
                      color: Colors.green.shade700,
                      size: 28,
                    ),
                    title: Text(
                      "${recyc["name"]}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 20),
                    onTap: () {
                      // Show login prompt when tapping on a cylinder type
                      _showLoginPrompt(recyc['']);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showLoginPrompt(String cylinder) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Login to Start Delivery"),
        content: Text(
          "Please log in to start delivery for the $cylinder cylinder.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.shade700,
            ),
            onPressed: () {
              Navigator.pop(context); // Close the prompt
              Navigator.pushNamed(context, '/authpage'); // Navigate to the login page
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }




  @override
  void initState() {
    super.initState();
    fetchbinSale();
    _fetchRiderData();
    fetchRecyclers();
  }

  void fetchbinSale() {
    _binsale.onValue.listen((event) {
      final binsalesMap = event.snapshot.value as Map<dynamic, dynamic>?;
      print("Fetched binsalesMap: $binsalesMap");

      if (binsalesMap != null) {
        final binsalesList = binsalesMap.entries
            .where((entry) {
          final data = Map<String, dynamic>.from(entry.value);
          final wmsInfo = Map<String, dynamic>.from(data['wasteManagementInfo'] ?? {});
          return wmsInfo['WMSTYPE'] == 'BinSale';
        })
            .map((entry) {
          final data = Map<String, dynamic>.from(entry.value);
          final wmsInfo = Map<String, dynamic>.from(data['wasteManagementInfo'] ?? {});

          final pickupBinsMap = Map<String, dynamic>.from(data['pickupBins'] ?? {});
          final pickupBinIds = pickupBinsMap.keys.toList();


          return {
            'name': wmsInfo['DirectorName'] ?? 'Unknown',
            'location': wmsInfo['location'] ?? '',
            'MobileNumber': wmsInfo['ghMobileNumber'] ?? '',
            'pickupBins': pickupBinIds,  // or pickupBinsMap if you need values too

          };
        }).toList();
        print("Final binsalesList: $binsalesList");

        setState(() {
          binsale = binsalesList;
        });
      }
    });
  }
  void fetchRecyclers() {
    _RECYCLE.onValue.listen((event) {
      final RECYCLESsMap = event.snapshot.value as Map<dynamic, dynamic>?;
      print("Fetched recycMap: $RECYCLESsMap");

      if (RECYCLESsMap != null) {
        final recyclerlist = RECYCLESsMap.entries
            .where((entry) {
          final data = Map<String, dynamic>.from(entry.value);
          final wmsInfo = Map<String, dynamic>.from(data['wasteManagementInfo'] ?? {});
          return wmsInfo['WMSTYPE'] == 'Recycle';
        })
            .map((entry) {
          final data = Map<String, dynamic>.from(entry.value);
          final wmsInfo = Map<String, dynamic>.from(data['wasteManagementInfo'] ?? {});

          final pickupBinsMap = Map<String, dynamic>.from(data['pickupBins'] ?? {});
          final pickupBinIds = pickupBinsMap.keys.toList();


          return {
            'name': wmsInfo['DirectorName'] ?? 'Unknown',
            'location': wmsInfo['location'] ?? '',
            'MobileNumber': wmsInfo['ghMobileNumber'] ?? '',
            'pickupBins': pickupBinIds,  // or pickupBinsMap if you need values too

          };
        }).toList();
        print("Final binsalesList: $recyclerlist");

        setState(() {
          RECYCLERS = recyclerlist;
        });
      }
    });
  }

  List<Map<String, dynamic>> riderList = [];

  Future<void> _fetchRiderData() async {
    try {
      final availableRiderSnapshot = await FirebaseDatabase.instance.ref('availableRider').get();

      if (availableRiderSnapshot.exists) {
        final availableRiderData = availableRiderSnapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> fetchedRiders = [];

        for (var entry in availableRiderData.entries) {
          final riderKey = entry.key;
          final riderInfo = entry.value as Map<dynamic, dynamic>;

          if (!riderInfo.containsKey('riderId')) {
            print("❌ Missing riderId for availableRider: $riderKey");
            continue;
          }

          final String riderId = riderInfo['riderId'];

          final riderSnapshot =
          await FirebaseDatabase.instance.ref('Rider/$riderId').get();

          if (riderSnapshot.exists) {
            final riderDetails = riderSnapshot.value as Map<dynamic, dynamic>;
            fetchedRiders.add(Map<String, dynamic>.from(riderDetails));
          } else {
            print("⚠️ Rider entry not found for riderId: $riderId");
          }
        }

        setState(() {
          riderList = fetchedRiders;
          isRiderLoading = false;
          riderExists = riderList.isNotEmpty;
        });
      } else {
        setState(() {
          riderExists = false;
          isRiderLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching rider data: $e");
      setState(() {
        isRiderLoading = false;
        riderExists = false;
      });
    }

  }

  Widget _buildRiderInfoCard() {
    if (isRiderLoading) return CircularProgressIndicator();

    if (riderExists && riderData != null) {
      return Card(
        margin: EdgeInsets.all(10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(riderData!['riderImageUrl'] ?? ''),
          ),
          title:
          Text('${riderData!['FirstName']} ${riderData!['LastName']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Phone: ${riderData!['phoneNumber']}"),
              // Text("Status: ${riderData!['status']}"),
              Text("Location: ${riderData!['location']}"),
            ],
          ),
        ),
      );
    }

    return SizedBox(); // No rider info to show
  }

  // Method to create the typewriter effect for the description
  Widget _buildTypewriterText(String text) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          speed: Duration(milliseconds: 100),
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white70),
        ),
      ],
      totalRepeatCount: 19,
      pause: Duration(milliseconds: 500),
      displayFullTextOnTap: true,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0x3a064d80),


      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Guest Mode",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor:   Color(0xff5e9667),

        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/onb21.jpg'),
                  // Add your background image
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1),
                  BlendMode.darken,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Introduction Card with Typewriter Effect and Icon
                  Card(
                    color: Color(0x8BE3F8FF),

                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0x15064d80),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.recycle, // FontAwesome Icon
                            size: 50,
                            color: Colors.green,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: _buildTypewriterText(
                              "BinSales, Recycling, Waste Management and More ",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Header text
                  SizedBox(height: 40),
                  Text(
                    "Explore Our Services",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),

                  // 🔥 NEW: Action Cards Row 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionCard(
                        title: 'About Us',
                        icon: Icons.info_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AboutPage(),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        title: 'Recyclers',
                        icon: Icons.list_alt,
                        onTap: () {
                          _showCylindersDialog();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  // 🔥 NEW: Action Cards Row 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // _buildActionCard(
                      //   title: 'Additional Branch',
                      //   icon: Icons.privacy_tip,
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => RecyclePage(),
                      //         )
                      //     );
                      //   },
                      // ),
                      _buildActionCard(
                        title: 'Bin Sale',
                        icon: Icons.location_on,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BinSalePage(binSales: binsale,),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionCard(
                        title: 'Delievery Calculator',
                        icon: Icons.privacy_tip,
                        onTap: () {
                          showCalculationDialog(context);
                          // Add privacy action if needed
                        },
                      ),     _buildActionCard(
                        title: 'SignUp',
                        icon: Icons.login,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => signin(),
                            ),
                          );
                        },
                      ),

                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ]),
    );
  }




}


class BinSalePage extends StatelessWidget {
  final List<Map<String, dynamic>> binSales;

  const BinSalePage({Key? key, required this.binSales}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/onb1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Explore as a Guest...',
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              speed: Duration(milliseconds: 70),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: binSales.length,
                    itemBuilder: (context, index) {
                      final sale = binSales[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showSaleDialog(context, sale),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Bin Sale Icon with Container
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.recycling,
                                    color: Colors.green.shade700,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Sale Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sale['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.grey.shade600,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            sale['location'],
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Status & Contact
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.end,
                                //   children: [
                                //     Container(
                                //       padding: const EdgeInsets.symmetric(
                                //           horizontal: 8, vertical: 4),
                                //       decoration: BoxDecoration(
                                //         color: _getStatusColor(sale['status']).withOpacity(0.1),
                                //         borderRadius: BorderRadius.circular(12),
                                //       ),
                                //       child: Text(
                                //         sale['status'],
                                //         style: TextStyle(
                                //           color: _getStatusColor(sale['status']),
                                //           fontWeight: FontWeight.w500,
                                //           fontSize: 12,
                                //         ),
                                //       ),
                                //     ),
                                //     const SizedBox(height: 8),
                                //     InkWell(
                                //       borderRadius: BorderRadius.circular(20),
                                //       onTap: () => _callSalePoint(sale['number']),
                                //       child: Padding(
                                //         padding: const EdgeInsets.all(4),
                                //         child: Row(
                                //           mainAxisSize: MainAxisSize.min,
                                //           children: [
                                //             Icon(
                                //               Icons.phone,
                                //               color: Colors.blue.shade700,
                                //               size: 16,
                                //             ),
                                //             const SizedBox(width: 4),
                                //             Text(
                                //               sale['number'],
                                //               style: TextStyle(
                                //                 color: Colors.blue.shade700,
                                //                 fontSize: 12,
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'busy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showSaleDialog(BuildContext context, Map<String, dynamic> sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sale['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${sale['location']}'),
            SizedBox(height: 8),
            Text('Status: ${sale['status']}'),
            SizedBox(height: 8),
            Text('Phone: ${sale['number']}'),
            SizedBox(height: 16),
            Text('Materials Accepted: ${sale['materials'] ?? 'Various'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () => _callSalePoint(sale['number']),
            child: Text('Call'),
          ),
        ],
      ),
    );
  }

  void _callSalePoint(String number) {
    // Implement calling functionality
    launchUrl(Uri.parse('tel:$number'));
  }
}
void _callStation(String number) {
  // Implement phone call functionality
  launchUrl(Uri.parse('tel:$number'));
}
// Helper functions
void _showStationDialog(BuildContext context, Map<String, dynamic> station) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Login Required"),
      content: Text("Please log in to order from ${station['name']}."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/authpage');
          },
          child: const Text("Login"),
        ),
      ],
    ),
  );
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'open':
      return Colors.green.shade700;
    case 'closed':
      return Colors.red.shade700;
    case 'busy':
      return Colors.orange.shade700;
    default:
      return Colors.grey.shade700;
  }
}


double gasAmount = 0.0;
double deliveryAmount = 0.0;

// Method to calculate the total amount including gas and delivery charges
double calculateTotal(double enteredAmount, DirectionDetails directionDetails) {
  // Calculate service charge as 5% of the entered amount
  double serviceCharge = enteredAmount * 0.05;

  // Calculate delivery fare based on direction details
  // deliveryAmount = AssistantMethods.calculateFares(directionDetails);

  // Total cost including cylinder price, service charge, and delivery fare
  return enteredAmount + serviceCharge + deliveryAmount;
}


// Method to show the explanation dialog with breakdown
void showCalculationDialog(BuildContext context) {
  // double totalAmount = calculateTotal();

  // Show the dialog with the explanation
  showDialog(
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),

        child: AlertDialog(
          title: Text("Calculation Breakdown", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueAccent)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Explanation:\n"
                      "1. The service charge is 5% of the amount you want to spend on the cylinder.\n"
                      "2. Delivery fare is calculated based on the distance and time it takes to deliver the gas to you.\n"
                      "   - If the distance is less than 500 meters, a flat fee of \GHS5 is applied.\n"
                      "   - Otherwise, the fare is calculated as \GHS0.011 per meter traveled.\n"
                      "   - The time fare is calculated based on the time it takes to complete the delivery, at a rate of \GHS0.20 per minute.\n\n"
                      "This breakdown gives you a clear idea of how the charges are applied.",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        ),
      );
    },
  );
}

// Example usage of the above method
void exampleUsage(BuildContext context) {
  // Example user input
  double enteredAmount = 100.0; // Amount the user wants to spend on the cylinder
  DirectionDetails directionDetails = DirectionDetails(distanceValue: 5000, durationValue: 300);

  // Show the calculation dialog
  showCalculationDialog(context);
}

// Dummy class to simulate direction details (distance and time)
class DirectionDetails {
  final int? distanceValue;
  final int? durationValue;

  DirectionDetails({this.distanceValue, this.durationValue});
}
Widget _buildActionCard({
  required String title,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      color:  Color(0x3a064d80) ,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        width: 150,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0x5EE3F8FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
          ],
        ),
      ),
    ),
  );
}


