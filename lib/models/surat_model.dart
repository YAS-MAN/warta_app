import 'package:flutter/material.dart';

// Tipe persyaratan surat
enum RequirementType {
  auto, // Otomatis dari profil user (KTP/KK)
  upload, // User perlu upload dokumen baru
  text, // User perlu isi teks
}

/// Merepresentasikan satu item persyaratan dalam pengajuan surat
class SuratRequirement {
  final String id; // ID unik, e.g. "ktp_scan", "form_f201"
  final String label; // Label singkat, e.g. "Scan KTP / E-KTP"
  final String description; // Penjelasan lengkap
  final RequirementType type;
  final String? autoSourceField; // Field profil: "ktpUrl" | "kkUrl"
  final String? hint; // Hint untuk input teks

  const SuratRequirement({
    required this.id,
    required this.label,
    required this.description,
    required this.type,
    this.autoSourceField,
    this.hint,
  });
}

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
  final List<SuratRequirement> requirements;
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
