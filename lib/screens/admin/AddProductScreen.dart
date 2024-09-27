import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easestore/screens/admin/ShowAllProducts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  String? selectedCategory;
  bool _isLoading = false;

  List<String> dropdownlist = [
    'Jeans',
    'Kurtis',
    'Saree',
    'Salwar',
    'Frock',
    'Shirt',
    'Short Top',
    'Baggies',
  ];

  List<XFile> imageFiles = []; // List to store selected images

  // Function to pick images from gallery
  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        imageFiles = pickedImages;
      });
    }
  }

  // Function to save product details to Firestore and upload images to Firebase Storage
  Future<void> saveProduct() async {
    if (productNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty ||
        selectedCategory == null ||
        imageFiles.isEmpty) {
      print("Please fill all fields and select images.");
      return;
    }

    setState(() {
      _isLoading = true; // Start loading indicator
    });

    List<String> imageUrls = [];
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("User not logged in.");
      setState(() {
        _isLoading = false; // Stop loading
      });
      return;
    }

    try {
      // Upload images to Firebase Storage
      for (XFile imageFile in imageFiles) {
        String imageName = const Uuid().v1(); // Unique image name using UUID
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child("product_images")
            .child(imageName)
            .putData(await imageFile.readAsBytes());

        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Add product data to Firestore
      DocumentReference productRef = await FirebaseFirestore.instance.collection("products").add({
        "productName": productNameController.text.trim(),
        "description": descriptionController.text.trim(),
        "price": double.parse(priceController.text.trim()),
        "category": selectedCategory,
        "imageUrls": imageUrls,
        "userEmail": currentUser.email,
        "stock": double.parse(stockController.text.trim()),
        "productid": const Uuid().v1(),
      });

      print("Product added successfully with ID: ${productRef.id}");

      // Clear form fields after successful submission
      productNameController.clear();
      descriptionController.clear();
      priceController.clear();
      stockController.clear();
      setState(() {
        imageFiles.clear();
      });

    } catch (e) {
      print("Error adding product: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
     Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShowAllProductsScreen(),
            
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          "ADD PRODUCTS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name Input
                    TextField(
                      controller: productNameController,
                      decoration: const InputDecoration(
                        hintText: 'Product Name',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description Input
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Price Input
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Price',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Stock Input
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Stock',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Category Dropdown
                    DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text("Select Category"),
                      isExpanded: true,
                      items: dropdownlist.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Image Picker Button
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Select Images'),
                    ),
                    const SizedBox(height: 10),

                    // Image Carousel
                    imageFiles.isNotEmpty
                        ? CarouselSlider.builder(
                            itemCount: imageFiles.length,
                            options: CarouselOptions(
                              enlargeCenterPage: true,
                              autoPlay: true,
                              viewportFraction: 0.8,
                            ),
                            itemBuilder: (BuildContext context, int index, _) {
                              return Image.file(
                                File(imageFiles[index].path),
                                fit: BoxFit.contain,
                              );
                            },
                          )
                        : const SizedBox(),

                    const SizedBox(height: 20),

                    // Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: saveProduct,
                        child: const Text('Add Product'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
