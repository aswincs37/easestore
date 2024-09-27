import 'package:easestore/firebase_options.dart';

import 'package:easestore/screens/Home_screen.dart';


import 'package:easestore/screens/cart_provider.dart';

import 'package:easestore/screens/mycart.dart';
import 'package:easestore/screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => CartProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EaseStore',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      // Set the initial route to SplashScreen
      home: const SplashScreen(), // SplashScreen is the starting page
      routes: {
        "/home": (context) => const HomeScreen(),
        "/cart": (context) => const MyCart(),
        // Add other routes as needed
      },
    );
  }
}
