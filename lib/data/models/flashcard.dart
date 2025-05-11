import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
import 'package:eng_dictionary/data/models/database_helper.dart';
import 'package:eng_dictionary/core/services/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Flashcard {
  String id;
  String frontContent;
  String backContent;
  bool isLearned;

  Flashcard({
    required this.id,
    required this.frontContent,
    required this.backContent,
    this.isLearned = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': frontContent,
      'back': backContent,
      'is_learned': isLearned,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      frontContent: json['front'],
      backContent: json['back'],
      isLearned: json['is_learned'] ?? false,
    );
  }
}