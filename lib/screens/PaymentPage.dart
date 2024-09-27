import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const PaymentPage({Key? key, required this.totalAmount, required this.cartItems}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPaymentMethod;

  // Function to store order details in Firestore
  Future<bool> storeOrderDetails() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        // User is not logged in
        throw Exception('User not logged in.');
      }

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'totalAmount': widget.totalAmount,
        'items': widget.cartItems,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'packed',
      });

      return true; // Indicate success
    } catch (e) {
      // Log the error and return false
      print('Error storing order details: $e');
      return false; // Indicate failure
    }
  }

  // Function to clear the cart (both locally and from Firestore)
  Future<void> clearCart() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Delete all cart items for the current user from Firestore
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete(); // Delete each cart item document
      }

      setState(() {
        widget.cartItems.clear(); // Clear the cart items locally
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose a payment method:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Credit/Debit Card'),
              leading: Radio(
                value: 'card',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value as String?;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('GPay'),
              leading: Radio(
                value: 'Gpay',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value as String?;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('PhonePay'),
              leading: Radio(
                value: 'PhonePay',
                groupValue: selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    selectedPaymentMethod = value as String?;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool success = await storeOrderDetails(); // Store order details
                if (success) {
                  await clearCart(); // Clear the cart from Firestore after successful payment

                  // Show fullscreen Lottie animation
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Prevent closing by tapping outside
                    builder: (context) {
                      return Dialog(
                        insetPadding: EdgeInsets.all(0), // Make sure it covers the whole screen
                        backgroundColor: Colors.transparent,
                        child: SizedBox(

                          child: Lottie.network(
                            "https://lottie.host/3f145e11-36ea-45d0-b910-fbc45bdca19f/viLUMDXrrd.json",
                            fit: BoxFit.cover, // Cover the entire screen
                          ),
                        ),
                      );
                    },
                  );

                  // Optionally navigate to another page after a short delay
                  Future.delayed(const Duration(seconds: 3), () {
                    Navigator.pop(context); // Close the dialog (Lottie)
                    Navigator.pop(context); // Return to the previous page or main screen
                  });
                } else {
                  // Show error message if order failed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to process payment. Please check your connection or try again.')),
                  );
                }
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
