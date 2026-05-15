import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/top_notification.dart';
import '../../models/surat_model.dart';
import '../../services/surat_service.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SuratPreviewView extends StatefulWidget {
  final String title;
  final Map<String, String> formValues;

  const SuratPreviewView({
    super.key,
    required this.title,
    this.formValues = const {},
  });

  @override
  State<SuratPreviewView> createState() => _SuratPreviewViewState();
}

class _SuratPreviewViewState extends State<SuratPreviewView> {
  static const Color bgApp = Color(0xFFE5E7EB);
  String _cachedCustomBody = "";

  Future<void> _kirimPengajuan() async {
    final user = context.read<AuthViewModel>().currentUser;
    if (user == null) {
      TopNotification.show(
        context: context,
        message: "Sesi login tidak ditemukan. Silakan login ulang.",
      );
      return;
    }

    try {
      await SuratService().submitSurat(
        user: user,
        jenisSurat: widget.title,
        customBody: _cachedCustomBody,
      );
      if (!mounted) return;
      TopNotification.show(
        context: context,
        message: "Permohonan ${widget.title} berhasil diajukan!",
        isSuccess: true,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
    } catch (_) {
      if (!mounted) return;
      TopNotification.show(
        context: context,
        message: "Pengajuan gagal dikirim. Coba lagi.",
      );
    }
  }

  String _formatTanggalSekarang() {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    final now = DateTime.now();
    return '${now.day} ${bulan[now.month]} ${now.year}';
  }

  String _generateNomorSurat(String rt, String rw) {
    final now = DateTime.now();
    final nomorUrut = now.millisecondsSinceEpoch % 1000;
    return '$nomorUrut/RT.${rt.padLeft(2, '0')}/RW.${rw.padLeft(2, '0')}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final nama = user?.nama ?? '-';
    final nik = user?.nik ?? '-';
    final alamat = user?.alamat ?? '-';
    final rt = user?.rt ?? '00';
    final rw = user?.rw ?? '00';
    final kelurahan = user?.kelurahan ?? '-';
    final kecamatan = user?.kecamatan ?? '-';
    final kabupaten = user?.kabupaten ?? 'Surabaya';

    return Scaffold(
      backgroundColor: bgApp,
      body: FutureBuilder<SuratModel?>(
        future: SuratService().getSuratByTitle(widget.title),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final surat = snapshot.data;

          // Kop surat dinamis
          final kopSurat = 'PEMERINTAH KOTA ${kabupaten.toUpperCase()}\n'
              'KECAMATAN ${kecamatan.toUpperCase()} - KELURAHAN ${kelurahan.toUpperCase()}';

          // Nomor surat
          final nomorSurat = _generateNomorSurat(rt, rw);

          // Isi surat dinamis
          final intro = 'Yang bertanda tangan di bawah ini, '
              'Kepala Kelurahan $kelurahan, '
              'Kecamatan $kecamatan, '
              'Kota $kabupaten, '
              'dengan ini menerangkan bahwa:\n\n';

          final dataDiri = 'Nama: $nama\n'
              'NIK: $nik\n'
              'Alamat: $alamat, RT $rt RW $rw\n\n';

          String isiTemplate = "";
          final t = widget.title.toUpperCase();
          String val(String key) {
            final v = widget.formValues[key];
            return (v != null && v.trim().isNotEmpty) ? v.trim() : '-';
          }

          if (t.contains("KARTU KELUARGA")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas bermaksud mengurus permohonan Kartu Keluarga (KK) dengan jenis permohonan: ${val('Jenis Permohonan KK')}.";
          } else if (t.contains("KARTU TANDA PENDUDUK")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas bermaksud mengurus permohonan Kartu Tanda Penduduk (KTP) dengan jenis permohonan: ${val('Jenis Permohonan KTP')}.";
          } else if (t.contains("AKTA KELAHIRAN")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas mengajukan permohonan penerbitan Akta Kelahiran untuk anak kandung dengan rincian sebagai berikut:\n"
                "Nama Anak: ${val('Nama Anak')}\n"
                "Tempat, Tanggal Lahir: ${val('Tempat Lahir')}, ${val('Tanggal Lahir Anak')}\n"
                "Demikian silsilah dan data kelahiran ini diterangkan agar dapat dipergunakan sebagaimana mestinya.";
          } else if (t.contains("AKTA KEMATIAN")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas melaporkan peristiwa kematian anggota keluarga/kerabat:\n"
                "Nama Almarhum/ah: ${val('Nama Almarhum/ah')}\n"
                "Tanggal Meninggal: ${val('Tanggal Meninggal')}\n"
                "Surat keterangan ini dibuat sebagai pengantar pencatatan kematian resmi.";
          } else if (t.contains("SURAT PINDAH")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas bermaksud melakukan perpindahan domisili/pindah keluar dari wilayah ini dengan rincian:\n"
                "Alamat Tujuan: ${val('Alamat Tujuan')}\n"
                "Alasan Pindah: ${val('Alasan Pindah')}";
          } else if (t.contains("TEMPAT USAHA") || t.contains("SITU")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas adalah pemilik usaha yang beroperasi di wilayah ini:\n"
                "Nama Usaha: ${val('Nama Usaha')}\n"
                "Jenis Usaha: ${val('Jenis Usaha')}\n"
                "Alamat Usaha: ${val('Alamat Usaha')}\n"
                "Surat keterangan ini diberikan sebagai pengantar legalitas tempat usaha.";
          } else if (t.contains("MENDIRIKAN BANGUNAN") || t.contains("IMB")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas mengajukan permohonan Izin Mendirikan Bangunan (IMB) dengan spesifikasi:\n"
                "Jenis Bangunan: ${val('Jenis Bangunan')}\n"
                "Lokasi/Alamat Bangunan: ${val('Alamat Bangunan')}";
          } else if (t.contains("REKLAME")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas mengajukan permohonan izin pemasangan media reklame/informasi:\n"
                "Jenis Reklame: ${val('Jenis Reklame')}\n"
                "Lokasi Pemasangan: ${val('Lokasi Pemasangan')}";
          } else if (t.contains("KERAMAIAN")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas mengajukan permohonan pengantar Izin Keramaian untuk penyelenggaraan kegiatan:\n"
                "Nama Acara: ${val('Nama Acara')}\n"
                "Tanggal Pelaksanaan: ${val('Tanggal Acara')}\n"
                "Lokasi Acara: ${val('Lokasi Acara')}";
          } else if (t.contains("DOMISILI")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas adalah benar berdomisili dan bertempat tinggal di wilayah ini. Surat keterangan ini dibuat untuk keperluan: ${val('Keperluan')}.";
          } else if (t.contains("TIDAK MAMPU")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas adalah warga yang berstatus tidak mampu secara ekonomi dengan perkiraan penghasilan rata-rata: Rp ${val('Penghasilan Per Bulan')} per bulan.\n"
                "Surat keterangan ini diberikan guna keperluan: ${val('Keperluan / Tujuan SKTM')}.";
          } else if (t.contains("KETERANGAN USAHA")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas memiliki dan mengelola usaha mandiri di wilayah ini:\n"
                "Nama Usaha: ${val('Nama Usaha')}\n"
                "Jenis Usaha: ${val('Jenis Usaha')}\n"
                "Alamat Lokasi Usaha: ${val('Alamat Usaha')}";
          } else if (t.contains("SKCK")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas adalah warga yang berkelakuan baik dan tidak sedang tersangkut perkara pidana. Surat pengantar ini diberikan guna kepengurusan SKCK untuk keperluan: ${val('Keperluan SKCK')}.";
          } else if (t.contains("AHLI WARIS")) {
            isiTemplate = "Menerangkan silsilah dan kedudukan ahli waris sah dari almarhum/ah: ${val('Nama Pewaris (Almarhum/ah)')} sesuai bukti dan kesaksian yang tercatat di kelurahan.";
          } else if (t.contains("BELUM MENIKAH")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas berstatus belum pernah menikah/lajang berdasarkan register kependudukan. Surat ini digunakan untuk keperluan: ${val('Keperluan')}.";
          } else if (t.contains("JANDA") || t.contains("DUDA")) {
            isiTemplate = "Menerangkan bahwa status perkawinan individu tersebut di atas adalah Janda/Duda. Surat keterangan ini diterbitkan guna keperluan: ${val('Keperluan')}.";
          } else if (t.contains("KUASA TANAH")) {
            isiTemplate = "Menerangkan bahwa individu tersebut di atas memberikan kuasa penuh atas pengelolaan properti/tanah kepada:\n"
                "Nama Penerima Kuasa: ${val('Nama Penerima Kuasa')}\n"
                "Objek Kuasa: ${val('Objek Kuasa (Tanah/Properti)')}";
          } else {
            isiTemplate = surat?.templateKonten ?? "Menerangkan bahwa individu di atas bermaksud mengurus keperluan administrasi sesuai ketentuan.";
          }

          final bodySurat = intro + dataDiri + isiTemplate;
          // Simpan ke cache untuk dikirimkan ke database saat submit
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _cachedCustomBody = bodySurat;
          });

          // Tanggal & lokasi
          final tanggalSurat = '$kabupaten, ${_formatTanggalSekarang()}';

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    // ── HEADER ────────────────────────────
                    SizedBox(
                      height: 180,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color.fromARGB(255, 83, 0, 0), Color(0xFF8B0000)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: 20,
                                    top: 20,
                                    child: Transform.rotate(
                                      angle: 12 * 3.14159 / 180,
                                      child: Image(
                                        image: const AssetImage('assets/icons/ic_document_after.png'),
                                        width: 140,
                                        height: 140,
                                        color: const Color.fromARGB(255, 58, 1, 1).withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () => Navigator.pop(context),
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Expanded(
                                          child: Text(
                                            "Preview Dokumen",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── KERTAS SURAT ────────────────────
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // KOP SURAT (dinamis dari data user)
                            Text(
                              kopSurat,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(height: 2, color: Colors.black87),
                            const SizedBox(height: 24),

                            // JUDUL SURAT
                            Text(
                              widget.title.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nomor: $nomorSurat',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                            ),
                            const SizedBox(height: 32),

                            // ISI SURAT (dinamis dari user + template)
                            Text(
                              bodySurat,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 16),

                            // Kalimat penutup
                            const Text(
                              'Demikian surat keterangan ini dibuat untuk dipergunakan sebagaimana mestinya.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.justify,
                            ),

                            const SizedBox(height: 48),

                            // TANDA TANGAN
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    tanggalSurat,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Icon(
                                    Icons.qr_code_2,
                                    size: 50,
                                    color: Color(0xFF22C55E),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Menunggu Persetujuan\n(Digital Signature)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol Ajukan
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _kirimPengajuan,
                      child: const Text(
                        "Ajukan Surat",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
