import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BinSalePage extends StatefulWidget {
  const BinSalePage({super.key});

  @override
  State<BinSalePage> createState() => _BinSalePageState();
}

class _BinSalePageState extends State<BinSalePage> {
  List<dynamic> soldBins = [];
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  var userName;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      DatabaseReference userRef =
      FirebaseDatabase.instance.ref().child('WMS').child(uid);

      DataSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        var userData = userSnapshot.value as Map<dynamic, dynamic>;

        setState(() {
          userName = userData['Username'];
          soldBins = userData['wasteManagementInfo']?['SoldBins'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  void _showBinsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Make the background transparent
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25), // Curved edges
            ),
            child: Column(
              children: [
                // Dialog header with a close button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Bins',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white54),
                Expanded(
                  child: soldBins.isEmpty
                      ? const Center(
                    child: Text(
                      'No bins available',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                      : ListView.builder(
                    itemCount: soldBins.length,
                    itemBuilder: (context, index) {
                      var bin = soldBins[index];
                      return _buildBinItem(
                        name: bin['bintypename'] ?? 'Unknown',
                        price: bin['price'] ?? 'N/A',
                        imagePath: bin['image'] ?? '',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Bin Sale',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: _buildCustomDrawer(),

      body: Container(
        decoration:const BoxDecoration(
            gradient: const LinearGradient(
      colors: [Colors.white, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),),
        child: Padding(
          padding:  EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showBinsDialog, // Show dialog when tapped
                    child: _buildCategoryCard('My Bins',
                        soldBins.length,  Colors.blue, // Start of gradient
                      Colors.green, // End of gradient
                      'assets/images/bin.png'),
                  ),
                  _buildCategoryCard('Bin Requests', 3,  Colors.blue, // Start of gradient
                    Colors.green, // End of gradient
                      'assets/images/b1.png'),
                  _buildCategoryCard('Meeting', 2,  Colors.blue, // Start of gradient
                    Colors.green, // End of gradient
                    'assets/images/',),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                "Bin Requests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Bin Sale App',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome Andrew!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Handle navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Handle navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      String title, int tasks, Color gradientStart, Color gradientEnd, String imageUrl) {
    return Container(
      width: 110,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3), // Darkens the image for better text visibility
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tasks Task${tasks > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBinItem({required String name, required String price, required String imagePath}) {
    return Card(
      color: Colors.white.withOpacity(0.9), // Semi-transparent background
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: imagePath.isNotEmpty
            ? Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 50, color: Colors.grey),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Price: \$${price}'),
      ),
    );
  }

}
