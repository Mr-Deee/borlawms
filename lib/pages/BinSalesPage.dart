import 'package:borlawms/Assistant/assistantmethods.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../Model/WMSDB.dart';
import 'Profilepage.dart';

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
    AssistantMethod.getCurrentOnlineUserInfo(context);
    _fetchUserInfo();
    fetchBinRequests();
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
          backgroundColor: Colors.transparent,
          // Make the background transparent
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.9, // 90% of screen width
            height: MediaQuery.of(context).size.height *
                0.8, // 80% of screen height
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Bin Sale',
          style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Sign Out'),
                    backgroundColor: Colors.white,
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Text('Are you certain you want to Sign Out?'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text(
                          'Yes',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          print('yes');
                          FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/SignIn", (route) => false);
                          // Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      drawer: _buildCustomDrawer(userName ?? ""),
      body: Stack(
        children: [


          // Background Image with Filter
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg4.jpg'), // Your background image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.1), // Dark overlay
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              // gradient: const LinearGradient(
              //   // colors: [Colors.white, Colors.white],
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              // ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  SizedBox(height: 54,),
                  Text(
                    'Hello, $userName!',
                    style:
                        const TextStyle(fontSize: 20, color:Colors.white,fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 18, color:Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showBinsDialog, // Show dialog when tapped
                        child: _buildCategoryCard(
                            'My Bins',
                            soldBins.length,
                            Colors.blue, // Start of gradient
                            Colors.green, // End of gradient
                            'assets/images/bin.png'),
                      ),
                      _buildCategoryCard(
                          'Bin Requests',
                          3,
                          Colors.blue, // Start of gradient
                          Colors.green, // End of gradient
                          'assets/images/b1.png'),
                      _buildCategoryCard(
                        'Sold Bins', 2, Colors.white, // Start of gradient
                        Colors.green, // End of gradient
                        'assets/images/',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Bin Requests",
                    style: TextStyle(color:Colors.white,fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 900,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchBinRequests(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child:  CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No bin requests found.');
                        }

                        final binRequests = snapshot.data!;
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),


                              ...binRequests.map((bin) => Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      bin['image'] ?? 'assets/images/wms.png',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bin['binType'] ?? 'Unknown Bin',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Company: ${bin['company'] ?? 'N/A'}",
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                          Text(
                                            "Price: GHS ${bin['price'] ?? '0'}",
                                            style: const TextStyle(color: Colors.white70),
                                          ),
                                          if (bin.containsKey('totalRequests'))
                                            Text(
                                              "Requests: ${bin['totalRequests']}",
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        );
                      },
                    ),
                  )







                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDrawer(String userName) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.green,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 43,
                  backgroundImage: AssetImage('assets/images/bwmslogo.png'),
                  foregroundColor: Colors.black,
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome $userName',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('My Request'),
            onTap: () {
              // Handle navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const ProfilePage()),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
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



  Future<List<Map<String, dynamic>>> fetchBinRequests() async {
    final ref = FirebaseDatabase.instance.ref("RequestBins");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final value = Map<String, dynamic>.from(entry.value);
        return value;
      }).toList();
    } else {
      return [];
    }
  }

  Widget _buildCategoryCard(String title, int tasks, Color gradientStart,
      Color gradientEnd, String imageUrl) {
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
            Colors.black.withOpacity(0.3),
            // Darkens the image for better text visibility
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

  Widget _buildBinItem(
      {required String name,
      required String price,
      required String imagePath}) {
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
class ProfilePageforBinSale extends StatefulWidget {
  const ProfilePageforBinSale({super.key});

  @override
  State<ProfilePageforBinSale> createState() => _ProfilePageforBinSaleState();
}

class _ProfilePageforBinSaleState extends State<ProfilePageforBinSale> {
  final formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    var email = Provider.of<WMS>(context, listen: false).riderInfo?.email ?? "";
    var fclientname = Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
    var lclientname = Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
    var phoneNumber =
        Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        //
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.more_vert),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.lightGreen,
            radius: 50,
            backgroundImage: AssetImage('assets/images/bwmslogo.png'), // Replace with your image asset
          ),
          const SizedBox(height: 10),
          Text(
            '$fclientname $lclientname',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '$email',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  EditProfilePage(email: email, firstname: fclientname, lastname: '', phone: phoneNumber, onSave: (RiderInfo updatedInfo) {  },)),
              );
            },
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // ProfileMenuItem(
                //   icon: Icons.settings,
                //   title: 'Bins Management',
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) =>    ViewMyBinsPage()
                //       ),);
                //
                //   },
                // ),
                ProfileMenuItem(
                  icon: Icons.call,
                  title: 'Customer Support',
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) =>    CustomerSupportService()
                    //   ),);
                  },
                ),

                // ProfileMenuItem(
                //   icon: Icons.info,
                //   title: 'Information',
                //   onTap: () {},
                // ),
                // ProfileMenuItem(
                //   icon: Icons.logout,
                //   title: 'Log Out',
                //   onTap: () {},
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiderInfo {
  final String firstname;
  final String lastname;
  final String email;
  final String phone;

  RiderInfo({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
  });
}
// Edit Profile Page
class EditProfilePage extends StatelessWidget {
  final String? email;
  final String? firstname;
  final String ?lastname;
  final String? phone;
  final Function(RiderInfo updatedInfo)? onSave;

  EditProfilePage({
    required this.email,
    required this.firstname,
    required  this.lastname,
    required this.phone,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    emailController.text = email!;
    firstnameController.text = firstname!;
    lastnameController.text = lastname!;
    phoneController.text = phone!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.lightGreenAccent,
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/bwmslogo.png'), // Replace with your image asset
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: () {
                            // Handle profile picture update
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: firstnameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    final updatedInfo = RiderInfo(
                      firstname: firstnameController.text,
                      lastname: lastnameController.text,
                      email: emailController.text,
                      phone: phoneController.text,
                    );
                    onSave!(updatedInfo);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Settings Page (Menu Item Example)
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

// Custom TextField for Edit Profile Page
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;

  const CustomTextField({Key? key, required this.label, required this.hint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
