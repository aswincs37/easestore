import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowAllProductsScreen extends StatelessWidget {
  const ShowAllProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var product = snapshot.data!.docs[index];

              return Card(
                margin: const EdgeInsets.all(10.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      if (product['imageUrls'] != null && product['imageUrls'].isNotEmpty)
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Image.network(
                            product['imageUrls'][0], // Display the first image
                           
                          ),
                        ),
                      const SizedBox(height: 10),

                      // Product Name
                      Text(
                        product['productName'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Product Description
                      Text(
                        product['description'] ?? 'No Description',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 5),

                      // Product Price
                      Text(
                        'Price: \$${product['price'].toString()}',
                        style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 5),

                      // Product Stock
                      Text(
                        'Stock: ${product['stock'].toString()}',
                        style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 5),

                      // Product Category
                      Text(
                        'Category: ${product['category'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),

                      // Delete Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Confirmation dialog before deleting
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: const Text("Are you sure you want to delete this product?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text("Delete"),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('products')
                                            .doc(product.id)
                                            .delete()
                                            .then((_) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Product Deleted'),
                                            ),
                                          );
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
