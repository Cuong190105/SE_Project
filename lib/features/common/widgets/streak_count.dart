import 'package:flutter/material.dart';

class StreakCount extends StatelessWidget {

final int streakCount = 5;
const StreakCount({super.key});

  @override
  Widget build(BuildContext context) {
    return  Row(
      children: [
        Text(
          "$streakCount",
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
      ],
    );
  }
}
