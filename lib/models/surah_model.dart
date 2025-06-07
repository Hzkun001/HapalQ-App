class Surah {
  final int number;
  final String name;
  final String arabic;
  final String latin;
  final int ayahCount;
  final String translation;
  final String type;

  Surah({
    required this.number,
    required this.name,
    required this.arabic,
    required this.latin,
    required this.ayahCount,
    required this.translation,
    required this.type,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: int.parse(json['nomor'].toString()),
      name: json['nama_latin'],
      arabic: json['nama'],
      latin: json['nama_latin'],
      ayahCount: json['jumlah_ayat'],
      translation: json['arti'],
      type: json['tempat_turun'],
    );
  }
}
