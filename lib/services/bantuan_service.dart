import '../models/faq_model.dart';

class BantuanService {
  Future<List<FaqModel>> getFaqs() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Mock network delay

    return [
      FaqModel(
        question: "Bagaimana cara melaporkan masalah?",
        answer: "Masuk ke menu Pengaduan, kemudian pilih kategori laporan (Keamanan, Kebersihan, Infrastruktur). Tuliskan detail laporan dan unggah foto bukti jika ada.",
      ),
      FaqModel(
        question: "Kapan jadwal ronda akan diperbarui?",
        answer: "Jadwal ronda diperbarui setiap akhir bulan oleh Ketua RT masing-masing dan akan disinkronisasi ke aplikasi pada tanggal 1.",
      ),
      FaqModel(
        question: "Apa syarat pembuatan surat pengantar?",
        answer: "Pastikan Anda melampirkan foto E-KTP dan Kartu Keluarga (KK). Untuk keperluan khusus, mungkin dibutuhkan dokumen tambahan sesuai jenis surat yang diajukan.",
      ),
      FaqModel(
        question: "Kenapa akun saya belum diverifikasi?",
        answer: "Proses verifikasi membutuhkan waktu 1-2 hari kerja karena tim admin RW akan mencocokkan NIK Anda dengan database kependudukan secara manual.",
      ),
    ];
  }
}
