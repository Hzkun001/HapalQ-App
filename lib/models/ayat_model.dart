class Ayat {
  final int number;
  final String arabic;
  final String latin;
  final String translation;
  final String? audioUrl;

  Ayat({
    required this.number,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.audioUrl,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      number: json['nomor'] ?? json['id'],
      arabic: json['ar'],
      latin: json['tr'],
      translation: json['idn'],
      audioUrl: json['audio'], // jika ada field audio per ayat
    );
  }
}
