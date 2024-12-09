import 'package:borlawms/Assistant/assistantmethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Model/WMSDB.dart';

class RecyclePage extends StatefulWidget {
  const RecyclePage({super.key});

  @override
  State<RecyclePage> createState() => _RecyclePageState();
}

class _RecyclePageState extends State<RecyclePage> {


  int _currentIndex = 0;

  // List of pages
  final List<Widget> _pages = [
    DashboardPage(),
    WalletPage(),
    SuccessPage(),
  ];
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethod.getCurrentOnlineUserInfo(context);
  }
  @override
  Widget build(BuildContext context) {
    var email = Provider.of<WMS>(context, listen: false).riderInfo?.email ?? "";
    var fclientname = Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
    var lclientname = Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
    var phoneNumber =
        Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";
    return Scaffold(

      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Success',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  TextEditingController searchController = TextEditingController();
  String selectedCategory = 'All'; // Default dropdown value
  List<String> categories = ['All', 'Metal', 'Plastic', 'Glass', 'Organic'];
  List<Map<dynamic, dynamic>> allItems = [];
  List<Map<dynamic, dynamic>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final database = FirebaseDatabase.instance.ref('recycle_items');
    final snapshot = await database.get();

    if (snapshot.value != null) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<dynamic, dynamic>> items = data.entries.map((entry) {
        return {
          'key': entry.key,
          ...entry.value as Map<dynamic, dynamic>,
        };
      }).toList();

      setState(() {
        allItems = items;
        filteredItems = allItems;
      });
    }
  }

  void filterItems(String query, String category) {
    setState(() {
      filteredItems = allItems.where((item) {
        final itemType = item['RecycleType']?.toString().toLowerCase() ?? '';
        final description = item['description']?.toString().toLowerCase() ?? '';
        final matchesQuery = query.isEmpty ||
            itemType.contains(query.toLowerCase()) ||
            description.contains(query.toLowerCase());
        final matchesCategory =
            category == 'All' || itemType == category.toLowerCase();

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  Future<void> openGoogleMaps(String location) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$location';
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  @override
  Widget build(BuildContext context) {

    var email = Provider.of<WMS>(context, listen: false).riderInfo?.email ?? "";
    var fclientname = Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
    var lclientname = Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
    var phoneNumber = Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";

    // Determine the time-based salutation
    String getTimeBasedSalutation() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning';
      } else if (hour < 17) {
        return 'Good Afternoon';
      } else {
        return 'Good Evening';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
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
                        child: Text('Yes', style: TextStyle(color: Colors.black)),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                              context, "/SignIn", (route) => false);
                        },
                      ),
                      TextButton(
                        child: Text('Cancel', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getTimeBasedSalutation()}\nStart Today! - $fclientname',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text('Total waste collected', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: 0.75,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search recycle items...',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      filterItems(value, selectedCategory);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: categories
                        .map((category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                        filterItems(searchController.text, selectedCategory);
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(child: Text('No items found'))
                  : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    leading: item['image_url'] != null
                        ? Image.network(item['image_url'],
                        width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.image),
                    title: Text(item['RecycleType'] ?? 'Unknown'),
                    subtitle: Text(item['description'] ?? 'No description'),
                    trailing: IconButton(
                      icon: Icon(Icons.directions),
                      onPressed: () => openGoogleMaps(item['location']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('\$9.999',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InfoChip('12', 'Transaction'),
                      InfoChip('8', 'Progress'),
                      InfoChip('4', 'Waiting'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.recycling),
                  ),
                  title: Text('Soda Can'),
                  subtitle: Text('1.0 Kg'),
                  trailing: Text(
                    '+ 2.099\$',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Success'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 16),
                    Text('Success', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Your password is successfully created'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Continue'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: Text('Show Success Dialog'),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;

  CategoryItem(this.title, this.icon);

  Future<void> _fetchAndShowRecycleItems(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('recycle_items');
      final snapshot = await databaseReference.orderByChild('RecycleType').equalTo(title).get();

      Navigator.pop(context); // Close the loading dialog

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>? ?? {};
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('$title RecycleType'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: data.entries.map((entry) {
                    final item = entry.value as Map<dynamic, dynamic>;
                    return ListTile(
                      title: Text(item['Description'] ?? 'Unnamed Item'),
                      subtitle: Text('Weight: ${item['size'] ?? 'N/A'}'),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No items found in this category.')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      print('Error fetching items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch items. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _fetchAndShowRecycleItems(context),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Icon(icon, color: Colors.green),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// Reusable Chip Widget
class InfoChip extends StatelessWidget {
  final String count;
  final String label;

  InfoChip(this.count, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
// }
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       appBar: AppBar(
//         actions: [IconButton(
//           onPressed: () {
//
//
//             showDialog<void>(
//               context: context,
//               barrierDismissible: false, // user must tap button!
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text('Sign Out'),
//                   backgroundColor: Colors.white,
//                   content: SingleChildScrollView(
//                     child: Column(
//                       children: <Widget>[
//                         Text('Are you certain you want to Sign Out?'),
//                       ],
//                     ),
//                   ),
//                   actions: <Widget>[
//                     TextButton(
//                       child: Text(
//                         'Yes',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                       onPressed: () {
//                         print('yes');
//                         FirebaseAuth.instance.signOut();
//                         Navigator.pushNamedAndRemoveUntil(
//                             context, "/SignIn", (route) => false);
//                         // Navigator.of(context).pop();
//                       },
//                     ),
//                     TextButton(
//                       child: Text(
//                         'Cancel',
//                         style: TextStyle(color: Colors.red),
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           icon: const Icon(
//             Icons.logout,
//             color: Colors.black,
//           ),
//         ),],
//       ),
//       body:Column(children: [
//
//       ],)
//     );
//   }
// }
