import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/darurat_model.dart';
import '../models/user_model.dart';

class DaruratService {
  // Simulating an API call with Future.delayed
  Future<List<KontakDaruratModel>> getKontakDarurat() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Mock network delay

    return [
      KontakDaruratModel(
        namaInstansi: "Polsek Setempat",
        nomorTelepon: "110",
        jarak: "1.2 km",
        jenisLayanan: "Keamanan & Ketertiban",
        iconCodePoint: Icons.local_police.codePoint,
        iconFontFamily: Icons.local_police.fontFamily!,
      ),
      KontakDaruratModel(
        namaInstansi: "Rumah Sakit Umum",
        nomorTelepon: "119",
        jarak: "2.5 km",
        jenisLayanan: "Ambulans & Gawat Darurat",
        iconCodePoint: Icons.local_hospital.codePoint,
        iconFontFamily: Icons.local_hospital.fontFamily!,
      ),
      KontakDaruratModel(
        namaInstansi: "Pemadam Kebakaran",
        nomorTelepon: "113",
        jarak: "3.0 km",
        jenisLayanan: "Kebakaran & Penyelamatan",
        iconCodePoint: Icons.fire_extinguisher.codePoint,
        iconFontFamily: Icons.fire_extinguisher.fontFamily!,
      ),
      KontakDaruratModel(
        namaInstansi: "Puskesmas Kecamatan",
        nomorTelepon: "021-1234567",
        jarak: "0.8 km",
        jenisLayanan: "Fasilitas Kesehatan",
        iconCodePoint: Icons.medical_services.codePoint,
        iconFontFamily: Icons.medical_services.fontFamily!,
      ),
      KontakDaruratModel(
        namaInstansi: "PLN (Gangguan Listrik)",
        nomorTelepon: "123",
        jarak: "-",
        jenisLayanan: "Layanan Pelanggan Listrik",
        iconCodePoint: Icons.electrical_services.codePoint,
        iconFontFamily: Icons.electrical_services.fontFamily!,
      ),
    ];
  }

  // ==========================================
  // REAL-TIME FIRESTORE INTEGRATION (TRACE)
  // ==========================================
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mengirim sinyal darurat (warga -> firestore)
  Future<void> sendEmergencySignal({
    required UserModel warga,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('emergencies').add({
        'uid': warga.uid,
        'namaWarga': warga.nama,
        'rt': warga.rt ?? '',
        'rw': warga.rw ?? '',
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
    } catch (e) {
      debugPrint("Error sending emergency signal: $e");
    }
  }

  /// Pak RT menandai bahwa darurat sudah diatasi / ditangani
  Future<void> resolveEmergency(String emergencyId) async {
    try {
      await _firestore.collection('emergencies').doc(emergencyId).update({
        'status': 'resolved',
      });
    } catch (e) {
      debugPrint("Error resolving emergency: $e");
    }
  }

  /// Dashboard Pak RT mendengarkan sinyal darurat aktif di RT-nya sendiri
  Stream<List<EmergencySignalModel>> streamActiveEmergencies(String rtId) {
    if (rtId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('emergencies')
        .where('rt', isEqualTo: rtId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencySignalModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
