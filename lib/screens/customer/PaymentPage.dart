import 'package:easestore/screens/customer/bottom_nav.dart';
import 'package:easestore/screens/customer/myorders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;

  const PaymentPage(
      {Key? key, required this.totalAmount, required this.cartItems})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPaymentMethod;
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  // Function to validate fields
  bool validateFields() {
    if (addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery Address is required.')),
      );
      return false;
    }
    if (pincodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pincode is required.')),
      );
      return false;
    }
    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method.')),
      );
      return false;
    }
    return true;
  }

  // Function to store order details in Firestore
  Future<bool> storeOrderDetails() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not logged in.');
      }

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'totalAmount': widget.totalAmount,
        'items': widget.cartItems
            .map((item) => {
                  'productName': item['productName'],
                  'productId': item[
                      'productId'], // Assuming you have 'productId' in cartItems
                  'quantity': item['quantity'],
                  'price': item['price'],
                })
            .toList(),
        'address': addressController.text, // Store delivery address
        'pincode': pincodeController.text, // Store pincode
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'packed',
      });

      return true; // Indicate success
    } catch (e) {
      print('Error storing order details: $e');
      return false; // Indicate failure
    }
  }

  // Function to clear the cart (both locally and from Firestore)
  Future<void> clearCart() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        widget.cartItems.clear();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pincodeController,
                decoration: const InputDecoration(
                  labelText: 'Pincode',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              Text(
                'Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                  if (validateFields()) {
                    // Validate fields before proceeding
                    bool success = await storeOrderDetails();
                    if (success) {
                      await clearCart();

                      // Show fullscreen Lottie animation
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return Dialog(
                            insetPadding: EdgeInsets.all(0),
                            backgroundColor: Colors.transparent,
                            child: SizedBox(
                              child: Lottie.network(
                                "https://lottie.host/3f145e11-36ea-45d0-b910-fbc45bdca19f/viLUMDXrrd.json",
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );

                      Future.delayed(const Duration(seconds: 3), () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MyOrdersPage(),
                          ),
                          (Route<dynamic> route) =>
                              false, // This condition will remove all previous routes
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Failed to process payment. Please check your connection or try again.')),
                      );
                    }
                  }
                },
                child: const Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
