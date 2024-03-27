import 'package:borlawms/pages/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 15.0);
    const pageDecoration = PageDecoration(
      pageColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      imageFlex: 1,
      bodyPadding: EdgeInsets.fromLTRB(10.0, 0.0, 16.0, 16.0),
      imagePadding: EdgeInsets.only(top: 10, left: 24, right: 30),
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "We are Borla",
          body:
              'Trash the Waste, Not the Planet! Join our waste management campaign to reduce, '
              'reuse, and recycle for a cleaner, greener future. 🌍♻️ #TrashTalk #WasteLessLiveMore".',
          image: Image(
            image: AssetImage('assets/images/wms.png'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "How To Sign UP?",
          body:
              "Tap 'New User? signup',to navigate to signup screen. and input credentials,\n"
              "Return and Signin to your account.",
          image: Image(
            image: AssetImage(
              'assets/images/signup.png',
            ),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "How To SignIn",
          body: "Enter your email and password.\n"
              "Tap Continue to signin "
              "",
          image: Image(
            image: AssetImage('assets/images/signin.png'),
          ),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Go Online",
          body: "Want To Recieve Requests? \n "
              "Hit the Toggle to go online. Receive Requests in minutes."
              "",
          image: Image(
            image: AssetImage('assets/images/toggle.png'),
          ),
          decoration: pageDecoration,
        ),
      ],

      // child: Container(),
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
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
    );
  }
}
