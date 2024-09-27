import 'package:easestore/screens/bottom_nav.dart';
import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final bool showBottomNavBar;
  final int initialIndex;
  const CustomScaffold(
      {super.key,
      required this.body,
      this.showBottomNavBar = false,
      this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar:
          showBottomNavBar ? const BottomNavBar() : null,
    );
  }
}
