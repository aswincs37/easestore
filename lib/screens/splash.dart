import 'dart:async';
import 'package:easestore/screens/bottom_nav.dart'; // Import BottomNavBar
import 'package:easestore/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    animationController.forward();
    Timer(const Duration(seconds: 3), () {
      // Check if the user is logged in
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // If logged in, navigate to BottomNavBar
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const BottomNavBar()));
      } else {
        // If not logged in, navigate to SignIn
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const SignIn()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
                  parent: animationController, curve: Curves.easeOut)),
              child: Image.asset(
                "images/black.png",
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
