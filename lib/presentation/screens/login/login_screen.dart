import 'package:click_it_app/data/data_sources/remote_data_source.dart';
import 'package:click_it_app/data/models/login_model.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/widgets/bottom_logo_widget.dart';
import 'package:click_it_app/presentation/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool showProgressBar = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                LogoWidget(),
                Container(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: userNameController,
                        keyboardType: TextInputType.emailAddress,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r"^[a-zA-Z0-9_]*$")),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        onSaved: (String? value) {
                          // This optional block of code can be used to run
                          // code when the user saves the form.
                        },
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: (String? value) {
                          return (value != null && value.contains('@'))
                              ? 'Do not use the @ char.'
                              : null;
                        },
                      ),
                      SizedBox(
                        height: 30.h,
                      ),

                      //  Align(
                      //     alignment: Alignment.center,
                      //     child: showProgressBar ? CircularProgressIndicator() : SizedBox()),
                      showProgressBar
                          ? CircularProgressIndicator()
                          : GestureDetector(
                              onTap: () async {
                                if (userNameController.text.isNotEmpty &&
                                    passwordController.text.isNotEmpty) {
                                  //show the progress indicator
                                  // Align(
                                  //   alignment: Alignment.center,
                                  //   child: showProgressBar ? CircularProgressIndicator() : SizedBox());

                                  loginApi(
                                    userNameController.text,
                                    passwordController.text,
                                    context,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                      msg: 'Please enter the credentials ',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              },
                              child: Container(
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                                height: 40.h,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const Spacer(),
                const BottomLogoWidget(),
                SizedBox(
                  height: 40.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  loginApi(userName, password, BuildContext context) {
    setState(() {
      showProgressBar = true;
    });

    // print('method called');
    LoginRequestModel requestModel = LoginRequestModel(userName, password);

    // print(requestModel.toJson());

    Client _client = Client();
    RemoteDataSource dataSource = RemoteDataSourceImple(_client);

    dataSource.login(requestModel).then((value) async {
      setState(() {
        showProgressBar = false;
      });
      // print(value.companyName);
      // print(value.companyId[0]);
      // print(value.roleId);

      //store the login credentials in shared preferences

      final SharedPreferences _sharedPreferences =
          await SharedPreferences.getInstance();

      _sharedPreferences.setString('company_name', value.companyName);
      _sharedPreferences.setString('company_id', value.companyId[0]);
      _sharedPreferences.setString('source', value.source);
      _sharedPreferences.setInt('role_id', value.roleId);
      _sharedPreferences.setString('uid', value.uid);

      value.companyId[0] == userName
          ? Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const HomeScreen(),
              ))
          : const AlertDialog(
              title: Text('Please enter the correct details'),
              actions: [],
            );
    }).catchError((error) {
      setState(() {
        showProgressBar = false;
      });
    });
  }
}
