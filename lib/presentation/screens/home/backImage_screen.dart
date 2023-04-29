import 'package:flutter/material.dart';

class BackImageScreen extends StatefulWidget {
  const BackImageScreen({Key? key}) : super(key: key);

  @override
  State<BackImageScreen> createState() => _BackImageScreenState();
}

class _BackImageScreenState extends State<BackImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BAck Image"),
      ),
    );
  }
}
