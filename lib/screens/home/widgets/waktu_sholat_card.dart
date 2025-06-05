import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaktuSholatCard extends StatefulWidget {
  const WaktuSholatCard({super.key});

  @override
  State<WaktuSholatCard> createState() => _WaktuSholatCardState();
}

class _WaktuSholatCardState extends State<WaktuSholatCard> {
  Map<String, String>? jadwalSholat;
  String? errorMessage;

  // Offset per waktu sholat (dalam menit)
  Map<String, int> offsetMinutes = {
    "Subuh": -9,   // 05:07 -> 04:58 (kurang 9 menit)
    "Dzuhur": 1,   // 12:19 -> 12:20 (+1 menit)
    "Ashar": -1,   // 15:43 -> 15:42 (-1 menit)
    "Maghrib": 0,  // 18:17 sudah benar
    "Isya": 2,     // 19:29 -> 19:31 (+2 menit)
  };

  @override
  void initState() {
    super.initState();
    loadPrayerTimes();
  }

  Future<void> loadPrayerTimes() async {
    try {
      final position = await _determinePosition();
      final times = await fetchPrayerTimes(position.latitude, position.longitude, 3);

      final adjustedTimes = <String, String>{};

      // Terapkan offset ke tiap waktu sholat
      for (var entry in times.entries) {
        final offset = offsetMinutes[entry.key] ?? 0;
        adjustedTimes[entry.key] = _addMinutes(entry.value, offset);
      }

      setState(() {
        jadwalSholat = adjustedTimes;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif. Silakan aktifkan lokasi.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak secara permanen, tidak bisa meminta izin.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, String>> fetchPrayerTimes(double lat, double lon, int method) async {
    final url = Uri.parse('https://api.aladhan.com/v1/timings?latitude=$lat&longitude=$lon&method=$method');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final timings = data['data']['timings'];

      return {
        "Subuh": timings["Fajr"],
        "Dzuhur": timings["Dhuhr"],
        "Ashar": timings["Asr"],
        "Maghrib": timings["Maghrib"],
        "Isya": timings["Isha"],
      };
    } else {
      throw Exception('Gagal memuat jadwal sholat dari server');
    }
  }

  String _addMinutes(String timeStr, int minutesToAdd) {
    final parts = timeStr.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    minute += minutesToAdd;
    if (minute < 0) {
      hour -= 1;
      minute += 60;
    }
    if (minute >= 60) {
      hour += minute ~/ 60;
      minute = minute % 60;
    }
    if (hour < 0) {
      hour += 24;
    }
    if (hour >= 24) {
      hour = hour % 24;
    }

    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    }
    if (jadwalSholat == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 247, 246, 246),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(80, 255, 255, 255),
                blurRadius: 6,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: jadwalSholat!.entries.map((item) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.key,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 4, 112, 13),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        // Slider offset untuk tiap waktu sholat
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: offsetMinutes.keys.map((key) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$key offset: ${offsetMinutes[key]} menit'),
                  Slider(
                    min: -15,
                    max: 15,
                    divisions: 30,
                    label: '${offsetMinutes[key]}',
                    value: offsetMinutes[key]!.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        offsetMinutes[key] = value.toInt();
                        // Setelah ubah offset, update jadwal sholat lagi
                        final originalTimes = jadwalSholat ?? {};
                        final newTimes = <String, String>{};
                        for (var entry in originalTimes.entries) {
                          final offset = offsetMinutes[entry.key] ?? 0;
                          newTimes[entry.key] = _addMinutes(entry.value, offset);
                        }
                        jadwalSholat = newTimes;
                      });
                    },
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
