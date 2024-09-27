import 'package:easestore/screens/admin/AddProductScreen.dart';
import 'package:easestore/screens/admin/CustomerFeedback.dart';
import 'package:easestore/screens/admin/CustomerOrder.dart';
import 'package:easestore/screens/admin/ShowAllProducts.dart';
import 'package:easestore/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout,color: Colors.red,),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
             Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignIn()),
      ); // Redirect to login screen or another appropriate page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline,color: Colors.white,),
              label: const Text('Add Product',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {
                // Navigate to Add Product screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProductScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
           
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt,color: Colors.white,),
              label: const Text('Show All Products',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {
                // Navigate to Show All Products screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShowAllProductsScreen()),
                );
              },
            ),
            const SizedBox(height: 20,),
             ElevatedButton.icon(
              icon: const Icon(Icons.list_alt,color: Colors.white,),
              label: const Text('Customer Orders',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {
               
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AdminOrdersPage()),
                );
              },
            ),
              const SizedBox(height: 20,),
             ElevatedButton.icon(
              icon: const Icon(Icons.list_alt,color: Colors.white,),
              label: const Text('Customer Feedbacks',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              onPressed: () {
               
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  const AdminFeedbackPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



