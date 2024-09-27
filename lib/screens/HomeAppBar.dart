import 'package:flutter/material.dart';


class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(25),
          child: Row(
            children: [
              const Icon(
                Icons.sort,
                size: 30,
                color: Color(0xFF0C0E2E),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "DP Shop",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C0E2E),
                  ),
                ),
              ),
              const Spacer(),
              Badge(
                backgroundColor: Colors.red,
                child: InkWell(
                  onTap: () {},
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
