import 'package:click_it_app/common/Utils.dart';
import 'package:click_it_app/presentation/screens/home/sync_server_screen.dart';
import 'package:click_it_app/presentation/screens/home/upload_images_screen.dart';
import 'package:click_it_app/presentation/screens/login/login_screen.dart';
import 'package:click_it_app/presentation/screens/sidepanel/about_us_screen.dart';
import 'package:click_it_app/presentation/screens/sidepanel/contact_screen.dart';
import 'package:click_it_app/presentation/screens/sidepanel/disclaimer_screen.dart';
import 'package:click_it_app/presentation/widgets/bottom_logo_widget.dart';
import 'package:click_it_app/presentation/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
 


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _scaffoldKey = GlobalKey<ScaffoldState>();


    String? companyName,companyId;

    

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCompanyDetails();


 
  


  }

 
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          endDrawer: AppDrawer(),
          body: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  margin: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$companyName ($companyId)',
                        style:const  TextStyle(
                          fontSize: 14,
                          color: Colors.deepOrange,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                        child: const Icon(
                          Icons.keyboard_arrow_left_sharp,
                          size: 35,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                const LogoWidget(),
                SizedBox(
                  height: 20.h,
                ),
                GestureDetector(
                  // ignore: avoid_print
                  onTap: () => _scanBarcode().then(
                    (value) {
                      if (value != null) {
                        Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: UploadImagesScreen(
                                gtin: value,
                              ),
                            ),);
                      }

                      // value == -1
                      //     ? Navigator.pop(context)
                      //     : Navigator.push(
                      //         context,
                      //         PageTransition(
                      //           type: PageTransitionType.rightToLeft,
                      //           child: UploadImagesScreen(
                      //             scanResult: value,
                      //           ),
                      //         ));
                    },
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.deepOrange,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Scan product barcode',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'or',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: SyncServerScreen(),
                    ),
                  ),

                  // onTap: () {
              
                  //   // Utils.showDialog(context, SimpleFontelicoProgressDialogType.normal, 'Normal');
                  //   _dialog.show(type: SimpleFontelicoProgressDialogType.spinner, message: '');
                  // },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(13),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: const Text(
                      'Sync with Server',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                Spacer(),
                BottomLogoWidget(),
              ],
            ),
          )),
    );
  }

  Future _scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );

      print('the value of bracode is $barcodeScanRes');
      return barcodeScanRes == '-1' ? null : barcodeScanRes;
    } on Exception catch (e) {
      print(e);
    }
  }

   getCompanyDetails()async {

    final SharedPreferences _sharedPreferences= await SharedPreferences.getInstance();
    String? company_name=_sharedPreferences.getString('company_name');
    String? company_id=_sharedPreferences.getString('company_id');

    setState(() {
      companyName=company_name;
      companyId=company_id;
      print(companyName);
      
    });
 
  }

}

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // margin: const EdgeInsets.only(
        //   right: 10,
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            const Divider(),
            Flexible(
              child: ListView(
                
            
                children: [
                  ListTile(
                    onTap: () => Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const AboutUs(),
                        )),
                    title: const Text('About Us'),
                  ),
                  ListTile(
                    onTap: () => Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: ContactDetails(),
                        )),
                    title: const Text('Contact Details'),
                  ),
                  ListTile(
                    onTap: () => Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const DisclaimerScreen(),
                      ),
                    ),
                    title: const Text('Disclaimer'),
                  ),
                  ListTile(
                    onTap: () => Share.share(
                      'check out my website https://www.gs1india.org/datakart',
                      subject: 'Please download ClickIt app',
                    ),
                    title: const Text('Share App'),
                  ),
                  ListTile(
                    onTap: () async {
                      final SharedPreferences _sharedPreferences =
                          await SharedPreferences.getInstance();
            
                      _sharedPreferences.clear().whenComplete(
                            () => Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: const LoginScreen(),
                                type: PageTransitionType.leftToRight,
                              ),
                            ),

                          );
                    },
                    title: const Text('Logout'),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 10,),


            Stack(children: [
                 Positioned(
                   bottom: 10,
                   left: 20,
                   child: Text('Version 1.0.0',style: TextStyle(fontSize: 18,fontStyle: FontStyle.normal,fontWeight: FontWeight.normal,color: Colors.deepOrange,),),),
                Image(
              image: AssetImage(
                'assets/images/img_sidepanel.png',
              ),
            ),
            ],),           
          ],
        ),
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage('assets/images/logo_datakart.png'),
        //   ),
        // ),
      ),
    );
  }
}
