import 'package:easestore/screens/PaymentPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MyCart extends StatefulWidget {
  const MyCart({Key? key}) : super(key: key);

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  // Stream to listen to cart items
  Stream<QuerySnapshot> getCartItems() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Function to update quantity
  void updateQuantity(String cartItemId, int quantity) {
    if (quantity > 0) {  // Ensure quantity is positive
      FirebaseFirestore.instance.collection('cart').doc(cartItemId).update({
        'quantity': quantity,
      });
    }
  }

  // Function to delete cart item
  void deleteCartItem(String cartItemId) {
    FirebaseFirestore.instance.collection('cart').doc(cartItemId).delete();
  }

  // Function to proceed to checkout
  void checkout() {
    double totalAmount = 0;
    List<Map<String, dynamic>> cartItems = [];

    FirebaseFirestore.instance.collection('cart').where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).get().then((snapshot) {
      snapshot.docs.forEach((cartItem) {
        int quantity = cartItem['quantity'] ?? 1;
        double price = cartItem['price'] * quantity;
        totalAmount += price;

        cartItems.add({
          'productName': cartItem['productName'],
          'quantity': quantity,
          'price': cartItem['price'],
          // 'imageUrl': cartItem['imageUrl'], // Add image URL if needed
        });
      });

      // Navigate to PaymentPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            totalAmount: totalAmount,
            cartItems: cartItems,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.green,
        actions: [
          // StreamBuilder to get total amount dynamically
          StreamBuilder<QuerySnapshot>(
            stream: getCartItems(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('₹0.00');

              double totalAmount = 0;
              snapshot.data!.docs.forEach((cartItem) {
                int quantity = cartItem['quantity'] ?? 1;
                double price = cartItem['price'] * quantity;
                totalAmount += price;
              });

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Total: ₹${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getCartItems(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No items in cart.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var cartItem = snapshot.data!.docs[index];
              int quantity = cartItem['quantity'] ?? 1; // Default quantity
              double price = cartItem['price'] * quantity;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Product Image
                      // ClipOval(
                      //   child: Image.network(
                      //     cartItem['imageUrl'], // Replace with your image field
                      //     width: 50,
                      //     height: 50,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                      const SizedBox(width: 16), // Spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartItem['productName'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Price: ₹${cartItem['price'].toStringAsFixed(2)}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    updateQuantity(cartItem.id, quantity - 1);
                                  },
                                ),
                                Text('$quantity', style: const TextStyle(fontSize: 18)),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    updateQuantity(cartItem.id, quantity + 1);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Total: ₹${price.toStringAsFixed(2)}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          deleteCartItem(cartItem.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: checkout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: const Text(
            'Proceed to Checkout',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
