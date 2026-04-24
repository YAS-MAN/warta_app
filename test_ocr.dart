void main() {
  // Simulating the exact layout based on the provided KTP image
  String realKtpText = '''
PROVINSI DKI JAKARTA
JAKARTA SELATAN
NIK : 3174070112040005
Nama : YASMAN YAZID
Tempat/Tgl Lahir : JAKARTA, 01-12-2004
Jenis kelamin : LAKI-LAKI Gol. Darah :-
Alamat : JL KARYA UTAMA GG II / 44
RT/RW : 004/003
Kel/Desa : GANDARIA UTARA
Kecamatan : KEBAYORAN BARU
Agama : ISLAM
Status Perkawinan BELUM KAWIN
Pekerjaan : PELAJAR/MAHASISWA
Kewarganegaraan WNI
Berlaku Hingga : SEUMUR HIDUP
  ''';

  Map<String, String> data = {};

  void extract(String text) {
    data.clear();
    
    String getCapsValueAfter(String keywordPtn) {
      final ptn = RegExp(r'' + keywordPtn + r'[\s\:\=\-]*([A-Z0-9\s\.\/\-\,]+?)\n', caseSensitive: false);
      final match = ptn.firstMatch(text);
      if (match != null) {
        String val = match.group(1)!.trim();
        // if the value is empty or just punctuation, maybe the value is on a different line.
        if (val.isEmpty || RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(val)) {
             return '';
        }
        return val;
      }
      return '';
    }

    // Provinsi
    final provMatch = RegExp(r'(?:PROVINSI)\s*([A-Z\s]+)', caseSensitive: false).firstMatch(text);
    if (provMatch != null) data['provinsi'] = provMatch.group(1)!.split('\n')[0].trim();

    // Kabupaten/Kota (Often the line immediately following Provinsi)
    final kabMatch = RegExp(r'(?:PROVINSI)[^\n]*\n([A-Z\s]+)', caseSensitive: false).firstMatch(text);
    if (kabMatch != null) data['kabupaten'] = kabMatch.group(1)!.split('\n')[0].trim();

    // NIK (16 digits)
    final nikMatch = RegExp(r'\b\d{16}\b').firstMatch(text);
    if (nikMatch != null) data['nik'] = nikMatch.group(0)!;

    // Nama
    final namaMatch = RegExp(r'(?:Nama|Narna|Name|Nma)[\s\:\=\-]*([A-Z\s\.,]+)', caseSensitive: false).firstMatch(text);
    if (namaMatch != null) data['nama'] = namaMatch.group(1)!.split('\n')[0].trim();

    // Tempat/Tgl Lahir
    final ttlMatch = RegExp(r'(?:Tempat|Tgl|Lahir|Tempat/Tgl Lahir|Tempat/Tq1 Lahir)[\s\:\=\-]*([A-Za-z0-9\s]+,?\s*\d{2}-\d{2}-\d{4})', caseSensitive: false).firstMatch(text);
    if (ttlMatch != null) data['ttl'] = ttlMatch.group(1)!.split('\n')[0].trim();

    // Jenis Kelamin
    final jkMatch = RegExp(r'((?:LAKI-LAKI|PEREMPUAN|LAKI - LAKI|LAKI))', caseSensitive: false).firstMatch(text);
    if (jkMatch != null) {
      String jk = jkMatch.group(1)?.replaceAll(' ', '').toUpperCase() ?? '';
      if(jk == 'LAKI') jk = 'LAKI-LAKI';
      data['jenis_kelamin'] = jk;
    }

    // Gol Darah (can be on the same line as Jenis Kelamin)
    final golMatch = RegExp(r'(?:Gol\.?\s*Darah|Darah)[\s\:\=\-]*([A|B|AB|O|0|\-]+)', caseSensitive: false).firstMatch(text);
    if (golMatch != null) {
      String gol = golMatch.group(1)!.replaceAll('-', '').trim();
      if (gol == '0') gol = 'O'; 
      if (gol == '') gol = '-';
      data['gol_darah'] = gol;
    }

    // Alamat
    final alamatMatch = RegExp(r'(?:Alamat)[\s\:\=\-]*([A-Za-z0-9\s\.\/\-]+)', caseSensitive: false).firstMatch(text);
    if (alamatMatch != null) {
      data['alamat'] = alamatMatch.group(1)!.split('\n')[0].trim();
    }

    // RT/RW
    final rtrwMatch = RegExp(r'(?:RT|RW|RT/RW|RTI/RW)[\s\:\=\-]*(\d{3})[\s\/\[\]\|\-]*(\d{3})', caseSensitive: false).firstMatch(text);
    if (rtrwMatch != null) {
      data['rt'] = rtrwMatch.group(1)!;
      data['rw'] = rtrwMatch.group(2)!;
    }

    // Kelurahan/Desa
    final kelMatch = RegExp(r'(?:Kel/Desa|Kel|Desa|ke1/Desa)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(text);
    if (kelMatch != null) {
       String kel = kelMatch.group(1)!.split('\n')[0].trim();
       if (kel == 'amin') {
         // It accidentally caught the end of "Jenis kelamin" when scanning the whole text!
         // Let's use getCapsValueAfter for these to be safe against OCR line jumps.
         kel = getCapsValueAfter(r'(?:Kel/Desa|Kel|Desa|ke1/Desa)');
       }
       data['kelurahan'] = kel;
    }

    // Kecamatan
    final kecMatch = RegExp(r'(?:Kecamatan|Kec|kecamatan)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(text);
    if (kecMatch != null) data['kecamatan'] = kecMatch.group(1)!.split('\n')[0].trim();

    // Agama
    final agamaMatch = RegExp(r'(?:Agama)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(text);
    if (agamaMatch != null) data['agama'] = agamaMatch.group(1)!.split('\n')[0].trim();

    // Status Perkawinan
    final statusMatch = RegExp(r'(?:Status\s*Perkawinan|Status)[\s\:\=\-]*([A-Z\s]+)', caseSensitive: false).firstMatch(text);
    if (statusMatch != null) data['status_perkawinan'] = statusMatch.group(1)!.split('\n')[0].trim();

    // Pekerjaan
    final pekerjaanMatch = RegExp(r'(?:Pekerjaan)[\s\:\=\-]*([A-Z\s\/]+)', caseSensitive: false).firstMatch(text);
    if (pekerjaanMatch != null) data['pekerjaan'] = pekerjaanMatch.group(1)!.split('\n')[0].trim();

    // Kewarganegaraan
    final kwMatch = RegExp(r'(?:Kewarganegaraan)[\s\:\=\-]*([A-Z0-9\s]+)', caseSensitive: false).firstMatch(text);
    if (kwMatch != null) {
       String kw = kwMatch.group(1)!.split('\n')[0].replaceAll(' ', '').trim();
       if (kw == 'WN1') kw = 'WNI';
       data['kewarganegaraan'] = kw;
    }
  }

  print("--- Real KTP Layout ---");
  extract(realKtpText);
  data.forEach((k, v) => print('${k}: ${v}'));
}
