import 'package:borlawms/Assistant/assistantmethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var email = Provider.of<WMS>(context, listen: false).riderInfo?.email ?? "";
    var fclientname = Provider.of<WMS>(context, listen: false).riderInfo?.firstname ?? "";
    var lclientname = Provider.of<WMS>(context, listen: false).riderInfo?.lastname ?? "";
    var phoneNumber =
        Provider.of<WMS>(context, listen: false).riderInfo?.phone ?? "";
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${getTimeBasedSalutation()}\n'
                  'Start Today! - $fclientname',
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
                        // Text('\$9.999',
                        //     style: TextStyle(
                        //         fontSize: 24,
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.green)),
                        SizedBox(height: 5),
                        Text('Total waste collected',
                            style: TextStyle(color: Colors.grey)),
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
            SizedBox(height: 20),
            Text('Waste Category', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CategoryItem('Plastic', Icons.local_drink),
                CategoryItem('Glass', Icons.wine_bar),
                CategoryItem('Metal', Icons.settings),
                CategoryItem('Organic', Icons.eco),
              ],
            ),
            SizedBox(height: 20),
            Text('Nearby Recycleables', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.map),
                  title: Text('OGG Bin Station'),
                  subtitle: Text('Sesame Street 223, Washington DC'),
                  trailing: Text('2.3 km'),
                ),
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

// Reusable Widget for Waste Categories
class CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;

  CategoryItem(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Icon(icon, color: Colors.green),
        ),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 14)),
      ],
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
