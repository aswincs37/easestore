import 'package:flutter/material.dart';
import 'package:easestore/screens/custom_scaffold.dart';

class FoodPage extends StatelessWidget {
  const FoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScaffold(
      body: SingleChildScrollView(child: Center(child: Text("Outfits"))),
    );
  }
}
