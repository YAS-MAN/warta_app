class KontakDaruratModel {
  final String namaInstansi;
  final String nomorTelepon;
  final String jarak;
  final String jenisLayanan;
  final int iconCodePoint;
  final String iconFontFamily;

  KontakDaruratModel({
    required this.namaInstansi,
    required this.nomorTelepon,
    required this.jarak,
    required this.jenisLayanan,
    required this.iconCodePoint,
    required this.iconFontFamily,
  });
}

class EmergencySignalModel {
  final String id;
  final String uid;
  final String namaWarga;
  final String rt;
  final String rw;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status; // 'active', 'resolved'

  EmergencySignalModel({
    required this.id,
    required this.uid,
    required this.namaWarga,
    required this.rt,
    required this.rw,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
  });

  factory EmergencySignalModel.fromMap(Map<String, dynamic> data, String id) {
    return EmergencySignalModel(
      id: id,
      uid: data['uid'] ?? '',
      namaWarga: data['namaWarga'] ?? 'Warga Anonim',
      rt: data['rt'] ?? '',
      rw: data['rw'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as dynamic).toDate() 
          : DateTime.now(),
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'namaWarga': namaWarga,
      'rt': rt,
      'rw': rw,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'status': status,
    };
  }
}
