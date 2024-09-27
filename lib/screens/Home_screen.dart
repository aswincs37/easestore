import 'package:easestore/screens/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = '';

  // Function to add product to the cart
  void addToCart(BuildContext context, String productId, String productName, double price) {
    FirebaseFirestore.instance.collection('cart').add({
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': 1, // Default quantity is 1
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to cart: $error')),
      );
    });
  }

  // Function to handle Buy Now
  void buyNow(BuildContext context, String productId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proceeding to checkout for product: $productId')),
    );
    // Add checkout navigation logic here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search Products',
                hintStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          // StreamBuilder for Products
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No Products Available'),
                  );
                }

                // Filtered product list based on search text
                final filteredProducts = snapshot.data!.docs.where((product) {
                  return (product['productName'] as String)
                      .toLowerCase()
                      .startsWith(searchText.toLowerCase());
                }).toList();

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredProducts.length,
                  // Inside the itemBuilder of GridView.builder
itemBuilder: (context, index) {
  var product = filteredProducts[index];

  return GestureDetector(
    onTap: () {
      // Navigate to ProductMoreDetailsPage and pass the product data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductMoreDetailsPage(product: product),
        ),
      );
    },
    child: Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Carousel Slider
          if (product['imageUrls'] != null && product['imageUrls'].isNotEmpty)
            CarouselSlider(
              items: product['imageUrls'].map<Widget>((imageUrl) {
                return Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }).toList(),
              options: CarouselOptions(
                height: 170,
                enlargeCenterPage: true,
                autoPlay: true,
                onPageChanged: (index, reason) {},
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product['productName'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Price: ₹${product['price'].toString()}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
},

                         
                  
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
