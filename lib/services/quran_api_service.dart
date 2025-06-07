import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah_model.dart';
import '../models/ayat_model.dart';

class QuranApiService {
  static List<Surah>? _cachedSurahList;
  static final Map<int, List<Ayat>> _cachedAyat = {};

  static Future<List<Surah>> fetchSurahList() async {
    if (_cachedSurahList != null) return _cachedSurahList!;
    try {
      final response = await http.get(Uri.parse('https://equran.id/api/surat'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _cachedSurahList = data.map((json) => Surah.fromJson(json)).toList();
        return _cachedSurahList!;
      } else {
        throw Exception('Failed to load surah');
      }
    } catch (e) {
      print('Error fetching surah: $e');
      rethrow;
    }
  }

  static Future<List<Ayat>> fetchAyatList(int surahNumber) async {
    if (_cachedAyat.containsKey(surahNumber)) return _cachedAyat[surahNumber]!;
    try {
      // Ambil ayat dari equran.id
      final response = await http.get(Uri.parse('https://equran.id/api/surat/$surahNumber'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayatList = data['ayat'];
        // Fetch audio secara paralel
        final List<Future<Ayat>> futures = ayatList.map<Future<Ayat>>((ayatJson) async {
          final ayatNumber = ayatJson['nomor'] ?? ayatJson['id'];
          String? audioUrl;
          try {
            final audioResp = await http.get(Uri.parse('https://api.alquran.cloud/v1/ayah/$surahNumber:$ayatNumber/ar.alafasy'));
            if (audioResp.statusCode == 200) {
              final audioData = json.decode(audioResp.body);
              audioUrl = audioData['data']?['audio'];
            }
          } catch (e) {
            audioUrl = null;
          }
          return Ayat.fromJson({...ayatJson, 'audio': audioUrl});
        }).toList();
        final result = await Future.wait(futures);
        _cachedAyat[surahNumber] = result;
        return result;
      } else {
        throw Exception('Failed to load ayat');
      }
    } catch (e) {
      print('Error fetching ayat: $e');
      rethrow;
    }
  }
}
