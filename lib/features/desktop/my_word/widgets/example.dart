import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Example extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const Example({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox( // Cố định chiều rộng phần label
          width: 90, // Bạn có thể điều chỉnh phù hợp
          child: Text(
            '$label:',
            style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                //hintText: 'Nhập ${label.toLowerCase()}...',
                hintStyle: TextStyle(color: Colors.blue.shade300),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
