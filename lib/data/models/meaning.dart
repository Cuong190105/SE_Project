import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eng_dictionary/core/services/auth_service.dart';
import 'package:eng_dictionary/data/models/database_helper.dart';
import 'package:eng_dictionary/core/services/api_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:typed_data';
import 'dart:convert';

class Meaning {
  String meaningId;
  String definition;
  String partOfSpeech;
  String us_phonetic;
  String uk_phonetic;
  String example1;
  String example2;
  Uint8List? usIpaAudio;
  Uint8List? ukIpaAudio;
  Uint8List? image;

  Meaning({
    required this.meaningId,
    this.definition = '',
    this.partOfSpeech = '',
    this.us_phonetic = '',
    this.uk_phonetic = '',
    this.example1 = '',
    this.example2 = '',
    this.usIpaAudio,
    this.ukIpaAudio,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'meaning_id': meaningId,
      'definition': definition,
      'part_of_speech': partOfSpeech,
      'us_phonetic': us_phonetic,
      'uk_phonetic': uk_phonetic,
      'example1': example1,
      'example2': example2,
      'us_ipa_audio': usIpaAudio != null ? base64Encode(usIpaAudio!) : null,
      'uk_ipa_audio': ukIpaAudio != null ? base64Encode(ukIpaAudio!) : null,
      'image': image != null ? base64Encode(image!) : null,
    };
  }

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      meaningId: json['meaning_id'],
      definition: json['definition'] ?? '',
      partOfSpeech: json['part_of_speech'] ?? '',
      us_phonetic: json['us_phonetic'] ?? '',
      uk_phonetic: json['uk_phonetic'] ?? '',
      example1: json['example1'] ?? '',
      example2: json['example2'] ?? '',
      usIpaAudio: json['us_ipa_audio'] != null
          ? base64Decode(json['us_ipa_audio'])
          : null,
      ukIpaAudio: json['uk_ipa_audio'] != null
          ? base64Decode(json['uk_ipa_audio'])
          : null,
      image: json['image'] != null
          ? base64Decode(json['image'])
          : null,
    );
  }
}