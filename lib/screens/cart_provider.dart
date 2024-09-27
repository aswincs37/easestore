import 'package:flutter/material.dart';

class CartItem {
  String name;
  double price;
  int quantity;
  
  CartItem({required this.name, required this.price, required this.quantity});

  String? get imagePath => null;
}

class CartProvider with ChangeNotifier {
  List<CartItem> cartItems = [];
  void addToCart(CartItem item) {
    cartItems.add(item);
    notifyListeners();
  }
}
