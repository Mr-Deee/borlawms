import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  // AboutPage({});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  double _width = 70;

  @override
  Widget build(BuildContext context) {
    // final bool isColapsed;
    // createIconMarker();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App icon or logo
              // Image.asset('assets/app_logo.png', width: 100, height: 100),

              // App name and version
              Center(
                child: Container(
                  width: 239.0, // Adjust the width as needed
                  height: 120, // Adjust the height as needed
                  child: Image.asset(
                    'assets/images/wms.png',
                  ),
                ),
              ),
              Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 8),
              ),

              // Description or information about the app
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Welcome to Borla, where we redefine waste management with innovation and sustainability at our core. '
                  'Our mission is simple yet powerful: to create a cleaner, greener future by revolutionizing the way we handle waste. '
                  'At Borla, we believe that responsible waste management is key to preserving our environment.'
                  ' We have designed a user-friendly platform that seamlessly connects individuals and businesses '
                  'with efficient waste disposal solutions. Whether you are a conscientious homeowner or a forward-thinking organization,'
                  '  With Borla , you not only manage your waste but also contribute to a sustainable, circular economy.'
                  'Join us on this journey towards a cleaner tomorrow. Together, lets make waste management not just a necessity,'
                  ' but a conscious choice for a brighter, more sustainable future..',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              Divider(
                thickness: 4,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
