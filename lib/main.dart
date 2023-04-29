import 'package:click_it_app/presentation/screens/Splash/splash_screen.dart';
import 'package:click_it_app/presentation/screens/home/home_screen.dart';
import 'package:click_it_app/presentation/screens/home/new_uploadscreen.dart';
import 'package:click_it_app/presentation/screens/home/upload.dart';

import 'package:click_it_app/presentation/screens/home/upload_images_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// void main() => runApp(
//   DevicePreview(
//     enabled: !kReleaseMode,
//     builder: (context) => MyApp(), // Wrap your app
//   ),
// );

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) => MaterialApp(
        title: 'ClickIt App',
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        debugShowCheckedModeBanner: false,
        //   home: UploadImagesScreen(gtin: "8904368501807"),
        // home: HomeScreen(),
        home: const UploadImagesScreen(
          gtin: '',
        ),
        builder: EasyLoading.init(),
      ),
      // builder: () => MaterialApp(
      //   title: 'ClickIt App',
      //   debugShowCheckedModeBanner: false,
      //   theme: ThemeData(
      //     primarySwatch: Colors.deepOrange,
      //   ),
      //   home: const SplashScreen(),
      // ),
    );
  }
}
