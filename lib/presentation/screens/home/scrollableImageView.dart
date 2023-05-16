import 'dart:convert';
import 'dart:io';
import 'package:click_it_app/data/core/apiClient.dart';
import 'package:click_it_app/data/data_sources/Local%20Datasource/photo_db_handler.dart';
import 'package:click_it_app/data/models/quality_model.dart';
import 'package:click_it_app/presentation/screens/home/show_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageUploadGrid extends StatefulWidget {
  const ImageUploadGrid({Key? key}) : super(key: key);

  @override
  State<ImageUploadGrid> createState() => _ImageUploadGridState();
}

class _ImageUploadGridState extends State<ImageUploadGrid> {
  File? frontImage, backImage, leftImage, rightImage;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  var deviceData = <String, dynamic>{};
//static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  DatabaseHelper? databaseHelper;

  String longitudeData = "";
  String latitudeData = "";
  String imei = "";

  //already available product images

  String? productFrontImage,
      productBackImage,
      productLeftImage,
      productRightImage;
  final ScrollController _controller = ScrollController();
  String qualityCheckUrl = "http://20.204.169.52:8080/get-score/front";
  var globalcheck = "";

//   // **Loader
  bool _loading = false;
  bool retakeBtnEnable = true;
  bool submitBtnActive = false;

  bool showProgressBar = false;

  List<bool> _selections = List.generate(8, (index) => false);

  Uint8List? frontImageFile, backImageFile, rightImageFile;

  String? imagePath;
  _onLoading() {
    setState(() {
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
          width: MediaQuery.of(context).size.width,
          height: kToolbarHeight,
          child: ElevatedButton(onPressed: () {}, child: Text("Submit"))),
      appBar: AppBar(
        title: Text("Upload Images"),
      ),
      body: Scrollbar(
          isAlwaysShown: true,
          controller: _controller,
          thickness: 10,
          radius: Radius.circular(20.0),
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: GridView.count(
                  controller: _controller,
                  crossAxisSpacing: 10,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  padding: EdgeInsets.all(5),
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => productFrontImage != null
                          ? bottomsheetShow(
                              context, productFrontImage!, 'frontImage')
                          : bottomsheetUploads(context, 'frontImage'),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: productFrontImage != null
                                    ? Container(
                                        child: Center(
                                          child: frontImage != null
                                              ? Image.file(
                                                  frontImage!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )
                                              : Image(
                                                  image: NetworkImage(
                                                      productFrontImage!),
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                ),
                                        ),
                                      )
                                    : DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(12),
                                        child: Container(
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: frontImage != null
                                                  ? Image.file(
                                                      frontImage!,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    )
                                                  : const SizedBox(),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Front Image'),
                            ],
                          ),
                          const Positioned(
                            right: 10,
                            top: 10,
                            child: Text("High"),
                            //  Icon(
                            //   Icons.camera_alt_outlined,
                            //   color: Colors.deepOrange,
                            // ),
                          ),
                        ],
                      ),
                    ),

                    // **Edited Image
                    GestureDetector(
                      onTap: () => productFrontImage != null
                          ? bottomsheetShow(
                              context, productFrontImage!, 'frontImage')
                          : bottomsheetUploads(context, 'frontImage'),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: productFrontImage != null
                                    ? Container(
                                        child: Center(
                                          child: frontImage != null
                                              ? Image.memory(
                                                  frontImageFile!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )
                                              : Image(
                                                  image: NetworkImage(
                                                      productFrontImage!),
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                ),
                                        ),
                                      )
                                    : DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(12),
                                        child: Container(
                                          child: Center(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: frontImage != null
                                                  ? Image.file(
                                                      frontImage!,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                    )
                                                  : const SizedBox(),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text('Edited Front Image'),
                            ],
                          ),
                          const Positioned(
                            right: 10,
                            top: 10,
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // GestureDetector(
                    //   onTap: () {},
                    //   child: frontImage != null
                    //       ? Card(
                    //           margin: const EdgeInsets.all(10),
                    //           shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(10)),
                    //           clipBehavior: Clip.antiAliasWithSaveLayer,
                    //           elevation: 5,
                    //           child: Container(
                    //             padding: const EdgeInsets.only(
                    //                 left: 16.0, right: 16.0, bottom: 15.0),
                    //             decoration: BoxDecoration(
                    //               // TODO ADD  BG Image File Image

                    //               image: DecorationImage(
                    //                 image: MemoryImage(frontImageFile!),
                    //                 fit: BoxFit.cover,

                    //                 // fit: BoxFit.fill,
                    //                 alignment: Alignment.center,
                    //               ),
                    //             ),
                    //             child: Column(
                    //               children: [
                    //                 Row(
                    //                   crossAxisAlignment: CrossAxisAlignment.start,
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceBetween,
                    //                   children: <Widget>[
                    //                     Align(
                    //                       alignment: Alignment.bottomRight,
                    //                       child: Text(
                    //                         "Edited",
                    //                         style: TextStyle(
                    //                             fontWeight: FontWeight.bold),
                    //                       ),
                    //                     )
                    //                     // Padding(
                    //                     //   padding: const EdgeInsets.all(8.0),
                    //                     //   child: Text(
                    //                     //     "High",
                    //                     //     style: TextStyle(color: Colors.red),
                    //                     //   ),
                    //                     // ),
                    //                   ],
                    //                 ),
                    //                 SizedBox(
                    //                   height: 40,
                    //                 ),
                    //                 GestureDetector(
                    //                     onTap: () {}, child: Icon(Icons.add)),
                    //               ],
                    //             ),
                    //           ),
                    //         )
                    //       : DottedBorder(
                    //           borderType: BorderType.RRect,
                    //           radius: const Radius.circular(12),
                    //           child: Container(
                    //             child: Center(
                    //               child: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(10),
                    //                   child: frontImage != null
                    //                       ? Image.memory(
                    //                           frontImageFile!,
                    //                           fit: BoxFit.cover,
                    //                           width: double.infinity,
                    //                         )
                    //                       : Text("No Image")),
                    //             ),
                    //           ),
                    //         ),
                    // ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image
                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Back",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "High",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image

                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Edited",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "High",
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image
                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Left",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "High",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image

                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Edited",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "High",
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image
                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Right"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                            SizedBox(
                              height: 32,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text("High"),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image

                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Edited",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "High",
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image
                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Top"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                            SizedBox(
                              height: 32,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text("High"),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image

                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Edited",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "High",
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image
                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Bottom"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                            SizedBox(
                              height: 32,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text("High"),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image

                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Edited",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "High",
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image
                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Nutrition Val"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                            SizedBox(
                              height: 32,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text("High"),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image

                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Edited",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "High",
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        height: 15,
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image
                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text("Ingredients"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                            SizedBox(
                              height: 32,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text("High"),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 15.0),
                        decoration: BoxDecoration(
                            // TODO ADD  Image File Image

                            // image: DecorationImage(
                            //   image: FileImage(frontImage!),
                            //   fit: BoxFit.cover,

                            //   // fit: BoxFit.fill,
                            //   alignment: Alignment.center,
                            // ),
                            ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "Edited",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Text(
                                //     "High",
                                //     style: TextStyle(color: Colors.red),
                                //   ),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                                onTap: () {}, child: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ]))),
    );
  }

  Future<dynamic> bottomsheetUploads(BuildContext context, String imageType) {
    print('the imageType in front image is $imageType');
    return showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.white,
      transitionBackgroundColor: Colors.yellow,
      builder: (context) {
        return Material(
          child: Container(
            height: 200,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ListTile(
                  onTap: () => pickImage('camera', imageType),
                  title: const Text('Camera'),
                ),
                const Divider(
                  height: 1.0,
                ),
                ListTile(
                  onTap: () => pickImage('gallery', imageType),
                  title: const Text('Gallery'),
                ),
                const Divider(
                  height: 2.0,
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  title: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> checkQuality() async {
    try {
      if (frontImage != null) {
        SanityCheck qc = SanityCheck();

        print('Enter');
        var stream = new http.ByteStream(frontImage!.openRead());
        stream.cast();

        var length = await frontImage!.length();
        var uri = Uri.parse(qualityCheckUrl);

        var request = new http.MultipartRequest('POST', uri);

        request.files
            .add(await http.MultipartFile.fromPath("front", frontImage!.path));

        var response = await request.send();

        var res = await http.Response.fromStream(response);

        dynamic resData = json.decode(res.body);
        qc = SanityCheck.fromJson(resData["sanity_check"]);
        // Printing response body in resdata
        print(resData['sanity_check']['front']);
        globalcheck = resData['sanity_check']['front'];
        print(response.statusCode);

        if (response.statusCode == 200) if (qc.front == "High" ||
            qc.front == "Medium") {
          // **Show Loader && show remove background image
          frontImageFile = await ApiClient().remo(imagePath!);

          Navigator.of(context).pop();

          print('image uploaded');
          print(globalcheck);
          submitBtnActive = true;

          setState(() {});
        } else {
          setState(() {
            retakeBtnEnable = true;
            submitBtnActive = false;
            // TODO Disble Submt
            Navigator.of(context).pop();
          });

          Alert(
            context: context,
            type: AlertType.error,
            title: "RESOLUTION ALERT",
            desc: "Please Upload High Quality Image.",
            buttons: [],
          ).show();

          // **image Resolution Low show alert box

          print('Image Resolition Low');
        }
        else {
          print("Failed 400 code");
        }
      } else {
        _onLoading();
        print(' Please Upload Image');
        Navigator.of(context).pop();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<dynamic> bottomsheetShow(
      BuildContext context, String imageType, String currentImageType) {
    return showCupertinoModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.white,
      transitionBackgroundColor: Colors.yellow,
      builder: (context) {
        return Material(
          child: Container(
            height: 200,
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: [
                ListTile(
                  onTap: () => Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: ShowImageScreeen(
                        image: imageType,
                      ),
                    ),
                  ),
                  title: const Text('View'),
                ),
                const Divider(
                  height: 1.0,
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);

                    bottomsheetUploads(context, currentImageType);
                  },
                  title: const Text('New Upload'),
                ),
                const Divider(
                  height: 2.0,
                ),
                ListTile(
                  onTap: () => Navigator.pop(context),
                  title: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Null> pickImage(String source, String imageType) async {
    try {
      final imagePicked = await ImagePicker().pickImage(
        source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
      );

      if (imagePicked != null) {
        imagePath = imagePicked.path;
        frontImageFile = await imagePicked.readAsBytes();
        //user has selected the image
        final imageTemporary = File(imagePicked.path);

        _cropImage(imageTemporary, imageType);

        setState(() {});
      } else {
        //checking if the user has selected the image
        if (imagePicked == null) return;
      }
    } on PlatformException catch (e) {
      frontImageFile = null;
      setState(() {});
      //exception could occur if the user has not permitted for the picker

      print('Failed to pick image: $e');
    }
  }

  Future<Null> _cropImage(File? image, String imageType) async {
    File? croppedFile = await ImageCropper().cropImage(
        sourcePath: image!.path,
        maxWidth: 420,
        maxHeight: 420,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
        ));

    if (croppedFile != null) {
      Navigator.pop(context, image);
      setState(() {
        Future.delayed(Duration(microseconds: 4));
        _onLoading();

        print('the current imagetype is $imageType');
        if (imageType == 'frontImage') {
          frontImage = croppedFile;
          checkQuality();
        } else if (imageType == 'backImage') {
          backImage = croppedFile;

          print(backImage);
        } else if (imageType == 'leftImage') {
          leftImage = croppedFile;
        } else {
          rightImage = croppedFile;
        }
      });
    }
  }
}
