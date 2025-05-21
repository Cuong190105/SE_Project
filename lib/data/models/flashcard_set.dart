import 'package:flutter/material.dart';
import 'flashcard.dart';
import 'flashcard_manager.dart';

class FlashcardSet {
  String id;
  String userEmail;
  String name;
  String description;
  List<Flashcard> cards;
  Color color;
  int progress;
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;
  bool isSample;
  bool isDeleted;

  FlashcardSet({
    required this.id,
    required this.userEmail,
    required this.name,
    this.description = '',
    required this.cards,
    required this.color,
    this.progress = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isSample = false,
    this.isDeleted = false,
  });

  int get totalCards => cards.length;

  double get progressPercentage => totalCards > 0 ? progress / totalCards : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'set_id': id,
      'user_email': userEmail,
      'name': name,
      'description': description,
      'cards': cards.map((card) => card.toJson()).toList(),
      'color': color.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_sample': isSample ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List<dynamic>?)?.map((cardJson) {
      if (cardJson is Map<String, dynamic>) {
        return Flashcard.fromJson(cardJson);
      } else {
        throw Exception('Invalid card JSON: $cardJson');
      }
    }).toList() ?? [];

    bool isSample = false;
    if (json['is_sample'] is int) {
      isSample = json['is_sample'] == 1;
    } else if (json['is_sample'] is String) {
      isSample = json['is_sample'] == '1' || json['is_sample'].toLowerCase() == 'true';
    } else if (json['is_sample'] is bool) {
      isSample = json['is_sample'] as bool;
    }

    bool isDeleted = false;
    if (json['is_deleted'] is int) {
      isDeleted = json['is_deleted'] == 1;
    } else if (json['is_deleted'] is String) {
      isDeleted = json['is_deleted'] == '1' || json['is_deleted'].toLowerCase() == 'true';
    } else if (json['is_deleted'] is bool) {
      isDeleted = json['is_deleted'] as bool;
    }

    return FlashcardSet(
      id: json['set_id']?.toString() ?? 'set_${DateTime.now().millisecondsSinceEpoch}',
      userEmail: json['user_email']?.toString() ?? 'unknown_user@example.com',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cards: cards,
      color: json['color'] is int
          ? Color(json['color'] as int)
          : FlashcardManager.getColorForIndex(cards.length),
      progress: cards.where((card) => card.isLearned && !card.isDeleted).length,
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at']?.toString() ?? DateTime.now().toIso8601String()),
      isSynced: true,
      isSample: isSample,
      isDeleted: isDeleted,
    );
  }
}