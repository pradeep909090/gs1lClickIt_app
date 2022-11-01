import 'dart:async';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/login/login_screen.dart';
import 'package:click_it_app/presentation/widgets/bottom_logo_widget.dart';
import 'package:click_it_app/presentation/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';




String? finalUserName;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // //crash app
    // FirebaseCrashlytics.instance.crash();
    //if the user already logged in then send the user to home screen
    // otherwise send the user to Login screen
    //firebse analytics setup

    getValidationData().whenComplete(() => Timer(
          const Duration(seconds: 3),
          () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => finalUserName == null
                  ? const LoginScreen()
                  : const HomeScreen(),
            ),
          ),
        ),);
 
  }

  Future getValidationData() async {
    final SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    var obtainedUserName = _sharedPreferences.getString('company_id');

    setState(() {
      finalUserName = obtainedUserName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Spacer(),
              LogoWidget(),
              Spacer(),
              BottomLogoWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
