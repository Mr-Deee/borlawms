import 'dart:ui';
import 'package:borlawms/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 3);
              });
            },
            children: [
              buildPage(
                backgroundImage: 'assets/images/onb.jpg',
                title: "We are Borla",
                body:
                'Trash the Waste, Not the Planet! Join our waste management campaign to reduce, reuse, and recycle for a cleaner, greener future🌍♻️.',
                image: 'assets/images/bwmslogo.png',
            titleColor:  Colors.green, bodyColor:  Colors.white,
                titleFontSize: 63, bodyFontSize: 15,
              ),
              buildPage(
                backgroundImage: 'assets/images/signonb1.jpg',
                title: "How To Sign Up?",
                body:
                "Tap 'New User? signup', navigate to signup screen, and input credentials.\nReturn and sign in to your account.",
                image: 'assets/images/signup.png',
                 titleColor:  Colors.white,
                  bodyColor:  Colors.white,
                titleFontSize: 33,
                bodyFontSize: 15,
              ),
              buildPage(
                backgroundImage: 'assets/images/signonb1.jpg',
                title: "How To Sign In",
                body: "Enter your email and password.\nTap Continue to sign in.",
                image: 'assets/images/signin.png',  titleColor:  Colors.white, bodyColor:  Colors.white,
                titleFontSize: 23,
                bodyFontSize: 15,
              ),
              buildPage(
                backgroundImage: 'assets/images/onb21.jpg',
                title: "Go Online",
                body: "Want To Receive Requests? \nToggle to go online and receive requests.",
                image: 'assets/images/toggle.png',
                titleColor:  Colors.green, bodyColor:  Colors.white,
                titleFontSize: 23, bodyFontSize: 65,
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: WormEffect(
                    dotColor: Colors.white10,
                    activeDotColor: Colors.green,
                  ),
                ),
                SizedBox(height: 50),
                onLastPage
                    ? ElevatedButton(
                  onPressed: () {
                    // Navigate to main page or home screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => signin()), // Ensure the class name is `SignIn`
                    );
                  },
                  child: Text('Get Started'),
                )
                    : TextButton(
                  onPressed: () {
                    _controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                  child: Container(
                    height: 43,
                    width: 120,
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(33)),
                      child: Center(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Next',style: TextStyle(color: Colors.green,fontSize: 19),),
                      ))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String backgroundImage,
    required String title,
    required String body,
    required String image,
    required Color titleColor,
    required Color bodyColor,
    required double titleFontSize,
    required double bodyFontSize,

  }) {
    return Stack(
      children: [
        // Background image with blur effect
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage,),
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3.30, sigmaY: 3.30),
            child: Container(
              color: Colors.black.withOpacity(0.2), // Add color overlay for better readability
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image, height: 230,width: 3002,),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,

                    color: titleColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  body,
                  style: TextStyle(fontSize: 16,                color: bodyColor,),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
