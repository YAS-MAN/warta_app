class UserModel {
  final String nama;
  final String nik;
  final String noTelp;
  final String domisili;
  final String role;
  final int poin;
  final int saldo;
  final String avatarUrl;

  UserModel({
    required this.nama,
    required this.nik,
    required this.noTelp,
    required this.domisili,
    required this.role,
    required this.poin,
    required this.saldo,
    required this.avatarUrl,
  });
}

class IuranModel {
  final String id;
  final String bulan;
  final int tahun;
  final int nominal;
  final String status; // "LUNAS", "BELUM DIBAYAR"
  final DateTime? tanggalBayar;

  IuranModel({
    required this.id,
    required this.bulan,
    required this.tahun,
    required this.nominal,
    required this.status,
    this.tanggalBayar,
  });
}

class JadwalRondaModel {
  final String id;
  final DateTime tanggal;
  final String hari;
  final String lokasi;
  final String regu;
  final List<String> anggota;

  JadwalRondaModel({
    required this.id,
    required this.tanggal,
    required this.hari,
    required this.lokasi,
    required this.regu,
    required this.anggota,
  });
}
