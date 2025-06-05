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
      number: json['nomor'],
      name: json['nama'],
      arabic: json['nama'], // bisa dipisah kalau ada field khusus arab
      latin: json['latin'],
      ayahCount: json['jumlah_ayat'],
      translation: json['arti'],
      type: json['tempat_turun'], // gunakan 'type' jika itu nama field JSON kamu
    );
  }
}
