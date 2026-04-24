import 'package:flutter/material.dart';

class SuratFieldModel {
  final String label;
  final String hint;
  final int maxLines;

  SuratFieldModel({
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });
}

class SuratModel {
  final String id;
  final String category;
  final String title;
  final String description;
  final int iconCodePoint;
  final String? iconFontFamily;
  final List<String> requirements;
  final List<SuratFieldModel> fields;
  final String templateKonten;

  SuratModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.requirements,
    required this.fields,
    required this.templateKonten,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: iconFontFamily);
}
