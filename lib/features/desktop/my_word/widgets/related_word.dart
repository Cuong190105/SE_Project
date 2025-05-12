import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RelatedWord extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const RelatedWord({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: TextStyle(fontSize: 16, color: Colors.blue.shade900, fontWeight: FontWeight.bold,),
        ),
        SizedBox(height: 5),
        Container(
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
          child:  TextField(
            controller: controller,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.blue.shade300),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
