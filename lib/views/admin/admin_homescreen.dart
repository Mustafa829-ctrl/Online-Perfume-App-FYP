import 'package:flutter/material.dart';

class AdminHomescreen extends StatefulWidget {
  const AdminHomescreen({super.key});

  @override
  State<AdminHomescreen> createState() => _AdminHomescreemState();
}

class _AdminHomescreemState extends State<AdminHomescreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new),
        title: Text("Admin"),
      ),
    );

  }
}
