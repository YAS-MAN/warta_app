import 'package:flutter/material.dart';

class AktivitasModel {
  final String userId;
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final String status; // "BERHASIL", "PROSES", "DITOLAK"
  
  // Icon related
  final int iconCodePoint;
  final String? iconFontFamily;
  final Color iconColor;
  final Color iconBgColor;
  final Color statusTextColor;
  final Color statusBgColor;

  AktivitasModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.iconColor,
    required this.iconBgColor,
    required this.statusTextColor,
    required this.statusBgColor,
  });
}
