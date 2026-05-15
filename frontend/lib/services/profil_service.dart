import '../models/profil_model.dart';

class UserService {
  Future<UserModel> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserModel(
      nama: "Budi Santoso",
      nik: "3271012345678901",
      noTelp: "0812-3456-7890",
      domisili: "RT 01 / RW 02, Blok C",
      role: "Warga",
      poin: 1250,
      saldo: 150000,
      avatarUrl: "assets/images/avatar.png",
    );
  }
}

class KeuanganService {
  Future<List<IuranModel>> getRiwayatIuran() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      IuranModel(id: "IUR-001", bulan: "Januari", tahun: 2024, nominal: 50000, status: "LUNAS", tanggalBayar: DateTime(2024, 1, 10)),
      IuranModel(id: "IUR-002", bulan: "Februari", tahun: 2024, nominal: 50000, status: "LUNAS", tanggalBayar: DateTime(2024, 2, 12)),
      IuranModel(id: "IUR-003", bulan: "Maret", tahun: 2024, nominal: 50000, status: "BELUM DIBAYAR"),
    ];
  }
}

class KeamananService {
  Future<List<JadwalRondaModel>> getJadwalRonda() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      JadwalRondaModel(
        id: "RND-001",
        tanggal: DateTime(2024, 3, 15),
        hari: "Jumat Malam",
        lokasi: "Pos Ronda Utama RT 01",
        regu: "Regu Rajawali",
        anggota: ["Budi Santoso", "Andi", "Tono", "Herman"],
      ),
      JadwalRondaModel(
        id: "RND-002",
        tanggal: DateTime(2024, 3, 22),
        hari: "Jumat Malam",
        lokasi: "Pos Ronda Utama RT 01",
        regu: "Regu Rajawali",
        anggota: ["Budi Santoso", "Andi", "Tono", "Herman"],
      ),
    ];
  }
}
