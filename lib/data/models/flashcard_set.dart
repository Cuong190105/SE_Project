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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_sample': isSample ? 1 : 0,
    };
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    final cards = (json['cards'] as List).map((cardJson) => Flashcard.fromJson(cardJson)).toList();
    return FlashcardSet(
      id: json['set_id'],
      userEmail: json['user_email'] ?? 'unknown_user@example.com',
      name: json['name'],
      description: json['description'] ?? '',
      cards: cards,
      color: FlashcardManager.getColorForIndex(cards.length),
      progress: cards.where((card) => card.isLearned).length,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isSynced: true,
      isSample: json['is_sample'] == 1,
    );
  }
}
