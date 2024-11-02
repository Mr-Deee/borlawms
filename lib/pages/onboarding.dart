import 'dart:ui';
import 'package:borlawms/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  static const String idScreen = "Onboard";

  OnBoardingPage({Key? key}) : super(key: key);

  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => signin()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 15.0);

    return Stack(
      children: [
        Container(
          color: Colors.blue, // Base blue background color
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 10), // Adjust blur intensity
            child: Container(
              color: Colors.blue.withOpacity(0.8), // Adjust opacity if needed
            ),
          ),
        ),
        IntroductionScreen(
          key: introKey,
          pages: [
            PageViewModel(
              title: "We are Borla",
              body:
              'Trash the Waste, Not the Planet! Join our waste management campaign to reduce, '
                  'reuse, and recycle for a cleaner, greener future🌍♻️.',
              image: Image.asset('assets/images/wms.png'),
              decoration: PageDecoration(
                titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white),
                bodyTextStyle: bodyStyle.copyWith(color: Colors.white),
                imagePadding: EdgeInsets.only(top: 10, left: 24, right: 30),
                boxDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/onb.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.1), // Adjust overlay color and opacity as desired
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
            PageViewModel(
              title: "How To Sign UP?",
              body:
              "Tap 'New User? signup', navigate to signup screen, and input credentials.\n"
                  "Return and sign in to your account.",
              image: Image.asset('assets/images/signup.png'),
              decoration: PageDecoration(
                titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white),
                bodyTextStyle: bodyStyle.copyWith(color: Colors.white),
                imagePadding: EdgeInsets.only(top: 10, left: 24, right: 30),
                boxDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background2.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
            PageViewModel(
              title: "How To SignIn",
              body: "Enter your email and password.\nTap Continue to sign in.",
              image: Image.asset('assets/images/signin.png'),
              decoration: PageDecoration(
                titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white),
                bodyTextStyle: bodyStyle.copyWith(color: Colors.white),
                imagePadding: EdgeInsets.only(top: 10, left: 24, right: 30),
                boxDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background3.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
            PageViewModel(
              title: "Go Online",
              body: "Want To Receive Requests? \nToggle to go online and receive requests.",
              image: Image.asset('assets/images/toggle.png'),
              decoration: PageDecoration(
                titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: Colors.white),
                bodyTextStyle: bodyStyle.copyWith(color: Colors.white),
                imagePadding: EdgeInsets.only(top: 10, left: 24, right: 30),
                boxDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background4.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white10.withOpacity(0.3),
                      BlendMode.clear,
                    ),
                  ),
                ),






























































































              ),
            ),
          ],
          onDone: () => _onIntroEnd(context),
          showSkipButton: true,
          dotsFlex: 0,
          nextFlex: 0,
          skip: const Text('Skip'),
          next: const Icon(Icons.arrow_forward),
          done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Color(0xFFBDBDBD),
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ],
    );
  }
}
