import 'package:carousel_slider/carousel_slider.dart';
import 'package:easestore/screens/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductMoreDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot product;

  const ProductMoreDetailsPage({super.key, required this.product});

  // Function to add product to the cart
  void addToCart(BuildContext context) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Ensure you have currentUser defined
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to your cart.')),
      );
      return;
    }

    final String productId = product.id;
    final String productName = product['productName'];
    final double price = product['price'];

    // Check if the product is already in the cart
    final cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: currentUser.uid)
        .where('productId', isEqualTo: productId)
        .get();

    if (cartSnapshot.docs.isNotEmpty) {
      // Product is already in the cart, show message and navigate to cart
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item is already in your cart.Check Your Cart'),
          backgroundColor: Colors.orange,
        ),
      );

      // Navigate to the cart page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const BottomNavBar(),
        ),
        (route) => false, // This removes all the previous routes.
      );
    } else {
      // Product not in the cart, proceed to add it
      FirebaseFirestore.instance.collection('cart').add({
        'userId': currentUser.uid, // Use UID instead of email
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': 1, // Default quantity is 1
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Added to cart', style: TextStyle(color: Colors.white)),
          ),
        );

        // Navigate to the cart page after adding the item
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const BottomNavBar(),
          ),
          (route) => false, // This removes all the previous routes.
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding to cart: $error')),
        );
      });
    }
  }

  // Function to handle Buy Now
  void buyNow(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding to checkout for product: ${product.id}')),
    );
    // Add checkout navigation logic here if needed
  }

  // Helper method to build image carousel
  Widget buildImageCarousel() {
    return product['imageUrls'] != null && product['imageUrls'].isNotEmpty
        ? CarouselSlider(
            items: product['imageUrls'].map<Widget>((imageUrl) {
              return Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              );
            }).toList(),
            options: CarouselOptions(
              height: 200,
              enlargeCenterPage: true,
              autoPlay: true,
            ),
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['productName']),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images
            buildImageCarousel(),
            const SizedBox(height: 16),

            // Product Name and Price
            Text(
              product['productName'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ₹${product['price'].toString()}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),

            // Product Description
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['description'] ?? 'No Description available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Stock and Category
            Text(
              'Stock: ${product['stock'].toString()}',
              style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${product['category'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Action Buttons: Buy Now and Add to Cart
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => buyNow(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'BUY NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => addToCart(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
