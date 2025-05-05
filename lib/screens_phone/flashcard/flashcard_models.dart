import 'dart:convert';
import 'package:flutter/material.dart';

class FlashcardSet {
  String id;
  String name;
  List<Flashcard> cards;
  Color color;
  int progress;

  FlashcardSet({
    required this.id,
    required this.name,
    required this.cards,
    required this.color,
    this.progress = 0,
  });

  int get totalCards => cards.length;

  double get progressPercentage => totalCards > 0 ? progress / totalCards : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cards': cards.map((card) => card.toJson()).toList(),
      'color': color.value,
      'progress': progress,
    };
  }

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      id: json['id'],
      name: json['name'],
      cards: (json['cards'] as List)
          .map((cardJson) => Flashcard.fromJson(cardJson))
          .toList(),
      color: Color(json['color']),
      progress: json['progress'],
    );
  }
}

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
      'frontContent': frontContent,
      'backContent': backContent,
      'isLearned': isLearned,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      frontContent: json['frontContent'],
      backContent: json['backContent'],
      isLearned: json['isLearned'],
    );
  }
}

class FlashcardManager {
  static List<FlashcardSet> _sets = [];

  static final List<Color> _defaultColors = [
    Colors.blue.shade700,
    Colors.purple.shade700,
    Colors.teal.shade700,
    Colors.amber.shade700,
    Colors.red.shade700,
    Colors.green.shade700,
    Colors.indigo.shade700,
    Colors.orange.shade700,
  ];

  static List<FlashcardSet> get sets => _sets;

  static Color getColorForIndex(int index) {
    return _defaultColors[index % _defaultColors.length];
  }

  static void loadSampleData() {
    if (_sets.isEmpty) {
      _sets = List.generate(
        8,
        (index) => FlashcardSet(
          id: 'set_${index + 1}',
          name: 'Bộ ${index + 1}',
          cards: List.generate(
            15,
            (cardIndex) => Flashcard(
              id: 'card_${index + 1}_${cardIndex + 1}',
              frontContent: 'English Word ${cardIndex + 1}',
              backContent: 'Nghĩa của từ ${cardIndex + 1}',
              isLearned: (cardIndex % 3 == 0),
            ),
          ),
          color: _defaultColors[index % _defaultColors.length],
          progress: index % 5,
        ),
      );
    }
  }

  static FlashcardSet? getSetById(String id) {
    try {
      return _sets.firstWhere((set) => set.id == id);
    } catch (e) {
      return null;
    }
  }

  static FlashcardSet createNewSet(String name) {
    final newId = 'set_${DateTime.now().millisecondsSinceEpoch}';
    final newSet = FlashcardSet(
      id: newId,
      name: name,
      cards: [],
      color: _defaultColors[_sets.length % _defaultColors.length],
    );

    _sets.add(newSet);
    return newSet;
  }

  static void renameSet(String setId, String newName) {
    final setIndex = _sets.indexWhere((set) => set.id == setId);
    if (setIndex != -1) {
      _sets[setIndex].name = newName;
    }
  }

  static void deleteSet(String setId) {
    _sets.removeWhere((set) => set.id == setId);
  }

  static Flashcard addCardToSet(
      String setId, String frontContent, String backContent) {
    final setIndex = _sets.indexWhere((set) => set.id == setId);
    if (setIndex == -1) {
      throw Exception('Flashcard set not found');
    }

    final newCard = Flashcard(
      id: 'card_${DateTime.now().millisecondsSinceEpoch}',
      frontContent: frontContent,
      backContent: backContent,
    );

    _sets[setIndex].cards.add(newCard);
    return newCard;
  }

  static void updateCard(
      String setId, String cardId, String frontContent, String backContent) {
    final setIndex = _sets.indexWhere((set) => set.id == setId);
    if (setIndex == -1) return;

    final cardIndex =
        _sets[setIndex].cards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return;

    _sets[setIndex].cards[cardIndex].frontContent = frontContent;
    _sets[setIndex].cards[cardIndex].backContent = backContent;
  }

  static void deleteCard(String setId, String cardId) {
    final setIndex = _sets.indexWhere((set) => set.id == setId);
    if (setIndex == -1) return;

    _sets[setIndex].cards.removeWhere((card) => card.id == cardId);
  }

  static void markCardAsLearned(String setId, String cardId, bool isLearned) {
    final setIndex = _sets.indexWhere((set) => set.id == setId);
    if (setIndex == -1) return;

    final cardIndex =
        _sets[setIndex].cards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return;

    _sets[setIndex].cards[cardIndex].isLearned = isLearned;

    // Update progress
    final learnedCount =
        _sets[setIndex].cards.where((card) => card.isLearned).length;
    _sets[setIndex].progress = learnedCount;
  }
}
