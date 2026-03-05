import 'package:flutter/material.dart';

class HomeStatusRow extends StatelessWidget {
  const HomeStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 23),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41', style: TextStyle(fontSize: 14)),
          Row(
            children: [
              Icon(Icons.signal_cellular_alt, size: 15),
              SizedBox(width: 5),
              Icon(Icons.wifi, size: 15),
              SizedBox(width: 5),
              Icon(Icons.battery_full, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
