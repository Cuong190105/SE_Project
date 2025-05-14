import 'package:flutter/material.dart';

class LogoBig extends StatelessWidget {
  const LogoBig({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.book,
            size: 50,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'DICTIONARY',
          softWrap: false,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}