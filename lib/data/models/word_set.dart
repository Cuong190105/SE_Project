import 'package:flutter/material.dart';
import 'flashcard.dart';
import 'flashcard_manager.dart';
import 'meaning.dart';
class WordSet {
  String id;
  bool deleted;
  String userEmail;
  String word;
  List<Meaning> meanings;
  String synonyms;
  String antonyms;
  String family;
  String phrases;
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;
  bool isSample;

  WordSet({
    required this.id,
    this.deleted = false,
    required this.userEmail,
    required this.word,
    required this.meanings,
    this.synonyms = '',
    this.antonyms = '',
    this.family = '',
    this.phrases = '',
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isSample = false,
  });


  Map<String, dynamic> toJson() {
    return {
      'word_id': id,
      'deleted': deleted ? 1 : 0,
      'user_email': userEmail,
      'word': word,
      'meanings': meanings.map((meaning) => meaning.toJson()).toList(),
      'synonyms': synonyms,
      'antonyms': antonyms,
      'family': family,
      'phrases': phrases,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_sample': isSample ? 1 : 0,
    };
  }

  factory WordSet.fromJson(Map<String, dynamic> json) {
    return WordSet(
      id: json['word_id'],
      deleted: json['deleted'] == 1,
      userEmail: json['user_email'] ?? 'unknown_user@example.com',
      word: json['word'],
      meanings: (json['meanings'] as List)
          .map((meaningJson) => Meaning.fromJson(meaningJson))
          .toList(),
      synonyms: json['synonyms'] ?? '',
      antonyms: json['antonyms'] ?? '',
      family: json['family'] ?? '',
      phrases: json['phrases'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isSynced: true,
      isSample: json['is_sample'] == 1,
    );
  }
}
