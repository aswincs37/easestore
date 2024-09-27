import 'package:easestore/screens/customer/Registration.dart';
import 'package:easestore/screens/admin/AdminHomeScreen.dart';
import 'package:easestore/screens/customer/bottom_nav.dart';
import 'package:easestore/screens/customer/forget_password.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedIn();
  }

  void _checkIfUserIsLoggedIn() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // User is already logged in, navigate to the bottom navigation bar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
        );
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddressController.text,
          password: passwordController.text);

      // Check if it's admin credentials
      if (emailAddressController.text == 'admin@gmail.com' &&
          passwordController.text == 'admin@123') {
        // Navigate to AdminHomeScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminHomeScreen(),
          ),
        );
      } else {
        // Navigate to HomeScreen for other users
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      var errorMessage = 'Incorrect Username or password.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      }
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
          currentFocus.focusedChild?.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
            
            child: Image(image: AssetImage("images/black.png")),
                ),
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please sign in to continue",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: emailAddressController,
                  style: const TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                  decoration: const InputDecoration(
                  
                    labelText: "EMAIL",
                    prefixIcon: Icon(Icons.email_outlined),
                    labelStyle: TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black, fontFamily: 'SFUIDisplay'),
                  decoration: InputDecoration(
                   
                    labelText: "PASSWORD",
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ForgetPassword(),
                        ));
                      },
                      child: const Text(
                        'FORGOT',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    labelStyle: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
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
                            "LOGIN",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 5),
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
        bottomNavigationBar: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(
                  fontFamily: 'SFUIDisplay',
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const RegistrationPage(),
                  ));
                },
                child: const Text(
                  "Sign Up",
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
      ),
    );
  }
}
