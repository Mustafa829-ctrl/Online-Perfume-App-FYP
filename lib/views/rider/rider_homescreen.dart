import 'package:flutter/material.dart';

class RiderHomescreen extends StatefulWidget {
  const RiderHomescreen({super.key});

  @override
  State<RiderHomescreen> createState() => _RiderHomescreenState();
}

class _RiderHomescreenState extends State<RiderHomescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new),
        title: Text("Rider"),
      ),
    );

  }
}
