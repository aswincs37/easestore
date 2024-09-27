import 'package:easestore/screens/login.dart';
import 'package:easestore/screens/customer/myorders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easestore/screens/customer/custom_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyAccount extends StatelessWidget {
  const MyAccount({super.key});

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to SignIn screen after logging out
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignIn()),
      );
    } catch (e) {
      print("Error signing out: $e");
      // Optionally show an error dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("No user is currently logged in."));
    }

    return CustomScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display user data dynamically from Firestore
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text("Error fetching user data."));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text("User not found."));
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String userName = userData['name'] ??
                      'User'; // Replace 'name' with your Firestore field
                  String userEmail = userData['email'] ??
                      'Email'; // Replace 'email' with your Firestore field

                  return Container(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, $userName",
                            style: const TextStyle(
                                fontSize: 22, color: Colors.deepPurple,fontWeight: FontWeight.bold),
                          ),
                         
                          // Text(
                          //   userEmail,
                          //   style: const TextStyle(
                          //       fontSize: 12, color: Colors.white),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Image.asset(
                'images/logo1.png',
                height: 200,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "My Account",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const ListOfOption(
                icon: Icon(
                  Icons.person_2_outlined,
                  color: Colors.green,
                ),
                title: 'Home',
              ),
              const ListOfOption(
                icon: Icon(
                  Icons.location_city_outlined,
                  color: Colors.green,
                ),
                title: 'Addresses',
              ),
              const ListOfOption(
                icon: Icon(
                  Icons.payment_outlined,
                  color: Colors.green,
                ),
                title: 'Payment',
              ),
              ListOfOption(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.green,
                ),
                title: 'Orders',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const MyOrdersPage()),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  'Settings',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const ListOfOption(
                icon: Icon(
                  Icons.language_outlined,
                  color: Colors.green,
                ),
                title: 'Language',
              ),
              ElevatedButton.icon(
                onPressed: () => logout(context),
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Change button color if needed
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListOfOption extends StatelessWidget {
  final Icon icon;
  final String title;
  final VoidCallback? onTap;

  const ListOfOption(
      {super.key, required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios_outlined,
        size: 16,
      ),
      onTap: onTap, // Add the onTap callback here
    );
  }
}
