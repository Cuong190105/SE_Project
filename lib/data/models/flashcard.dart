import 'package:flutter/material.dart';

class Flashcard {
  String id;
  String frontContent;
  String backContent;
  bool isLearned;
  bool isDeleted;

  Flashcard({
    required this.id,
    required this.frontContent,
    required this.backContent,
    this.isLearned = false,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': frontContent,
      'back': backContent,
      'is_learned': isLearned,
      'is_deleted': isDeleted,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id']?.toString() ?? 'card_${DateTime.now().millisecondsSinceEpoch}',
      frontContent: json['front']?.toString() ?? '',
      backContent: json['back']?.toString() ?? '',
      isLearned: json['is_learned'] is bool
          ? json['is_learned']
          : (json['is_learned'] is int
          ? json['is_learned'] == 1
          : (json['is_learned'] is String
          ? json['is_learned'].toLowerCase() == 'true' || json['is_learned'] == '1'
          : false)),
      isDeleted: json['is_deleted'] is bool
          ? json['is_deleted']
          : (json['is_deleted'] is int
          ? json['is_deleted'] == 1
          : (json['is_deleted'] is String
          ? json['is_deleted'].toLowerCase() == 'true' || json['is_deleted'] == '1'
          : false)),
    );
  }
}