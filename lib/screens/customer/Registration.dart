import 'package:easestore/screens/customer/Home_screen.dart';
import 'package:easestore/screens/customer/bottom_nav.dart';
import 'package:easestore/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();

  Future<void> registerUser() async {
    if (passwordController.text != conPasswordController.text) {
      // Show error if passwords do not match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    try {
      // Create the user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Add the user details to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid) // Use UID as document ID
          .set({
        'name': nameController.text,
        'email': emailController.text,
        'uid': userCredential.user!.uid,
      });

      // Navigate to HomeScreen on successful registration
    Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(
    builder: (context) => const BottomNavBar(),
  ),
  (route) => false, // This removes all the previous routes.
);

     
    } catch (e) {
      // Show error message if registration fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 110, 20, 110),
            child: Column(
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFields(
                  label: 'FULL NAME',
                  icon: const Icon(Icons.person_2_outlined),
                  controller: nameController,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFields(
                  label: 'Email',
                  icon: const Icon(Icons.email_outlined),
                  controller: emailController,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFields(
                  label: 'PASSWORD',
                  secureText: true,
                  icon: const Icon(Icons.lock_outlined),
                  controller: passwordController,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFields(
                  label: 'CONFIRM PASSWORD',
                  secureText: true,
                  icon: const Icon(Icons.lock_outlined),
                  controller: conPasswordController,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registerUser, // Trigger registration logic
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "SIGN UP",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 24,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Already have an account?",
              style: TextStyle(
                fontFamily: 'SFUIDisplay',
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SignIn(),
                ));
              },
              child: const Text(
                "Sign In",
                style: TextStyle(
                  fontFamily: 'SFUIDisplay',
                  color: Colors.green,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TextFields extends StatelessWidget {
  final Icon icon;
  final String label;
  TextEditingController controller;
  bool secureText;

  TextFields({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    this.secureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextFormField(
        controller: controller,
        obscureText: secureText,
        style: const TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          prefixIcon: icon,
          labelStyle: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
