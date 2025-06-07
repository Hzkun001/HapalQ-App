import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JadwalSholatScreen extends StatefulWidget {
  const JadwalSholatScreen({super.key});

  @override
  State<JadwalSholatScreen> createState() => _JadwalSholatScreenState();
}

class _JadwalSholatScreenState extends State<JadwalSholatScreen> {
  String _lokasi = 'Mencari lokasi...';
  bool _locationError = false;
  Map<String, String>? _jadwal;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getLocationAndJadwal();
  }

  Future<void> _getLocationAndJadwal() async {
    setState(() { _loading = true; });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _lokasi = 'Layanan lokasi mati'; _locationError = true; _loading = false; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _lokasi = 'Izin lokasi ditolak'; _locationError = true; _loading = false; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _lokasi = 'Izin lokasi permanen ditolak'; _locationError = true; _loading = false; });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _lokasi = 'Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}';
        _locationError = false;
      });
      // Fetch jadwal sholat dari API (bisa diganti ke API lain jika diinginkan)
      final now = DateTime.now();
      final url = 'https://api.myquran.com/v2/sholat/jadwal/${position.latitude},${position.longitude}/${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final jadwal = data['data']['jadwal'];
        setState(() {
          _jadwal = {
            'Subuh': jadwal['subuh'],
            'Dzuhur': jadwal['dzuhur'],
            'Ashar': jadwal['ashar'],
            'Maghrib': jadwal['maghrib'],
            'Isya': jadwal['isya'],
          };
        });
      } else {
        setState(() { _jadwal = null; });
      }
      setState(() { _loading = false; });
    } catch (e) {
      setState(() { _lokasi = 'Gagal mendapatkan lokasi/jadwal'; _locationError = true; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF04700D);
    final Color accent = const Color(0xFFCAFBDC);
    final now = DateTime.now();
    String? nextPrayer;
    String? nextPrayerTime;
    if (_jadwal != null) {
      final times = [
        {'name': 'Subuh', 'time': _jadwal!['Subuh']},
        {'name': 'Dzuhur', 'time': _jadwal!['Dzuhur']},
        {'name': 'Ashar', 'time': _jadwal!['Ashar']},
        {'name': 'Maghrib', 'time': _jadwal!['Maghrib']},
        {'name': 'Isya', 'time': _jadwal!['Isya']},
      ];
      for (var t in times) {
        if (t['time'] != null) {
          final tTime = DateFormat('HH:mm').parse(t['time']!);
          final todayTime = DateTime(now.year, now.month, now.day, tTime.hour, tTime.minute);
          if (todayTime.isAfter(now)) {
            nextPrayer = t['name'];
            nextPrayerTime = t['time'];
            break;
          }
        }
      }
      nextPrayer ??= 'Subuh';
      nextPrayerTime ??= _jadwal!['Subuh'];
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Sholat'),
        backgroundColor: primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getLocationAndJadwal,
            tooltip: 'Refresh Lokasi',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: primary, size: 22),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _lokasi,
                              style: TextStyle(fontSize: 15, color: _locationError ? Colors.red : primary, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_jadwal != null)
                      Column(
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                              child: Column(
                                children: _jadwal!.entries.map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _getPrayerIconWidget(e.key),
                                          const SizedBox(width: 10),
                                          Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black, fontFamily: 'Amiri')),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: accent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(e.value, style: TextStyle(fontSize: 16, color: primary, fontWeight: FontWeight.w600, fontFamily: 'Amiri')),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: accent, width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.access_time, color: primary, size: 28),
                                const SizedBox(width: 10),
                                Text(
                                  'Sholat berikutnya: ',
                                  style: TextStyle(fontSize: 16, color: primary, fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
                                ),
                                Text(
                                  nextPrayer != null && nextPrayerTime != null ? '$nextPrayer ($nextPrayerTime)' : '-',
                                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _iconInfo(Icons.wb_twighlight, 'Subuh'),
                              _iconInfo(Icons.wb_sunny, 'Dzuhur'),
                              _iconInfo(Icons.wb_cloudy, 'Ashar'),
                              _iconInfo(Icons.nights_stay, 'Maghrib'),
                              _iconInfo(Icons.nightlight_round, 'Isya'),
                            ],
                          ),
                        ],
                      )
                    else
                      const Text('Jadwal tidak tersedia', style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 24),
                    const Text('Jadwal sholat diambil otomatis berdasarkan lokasi Anda.', style: TextStyle(fontSize: 15, color: Colors.black54), textAlign: TextAlign.center),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _getPrayerIconWidget(String name) {
    switch (name.toLowerCase()) {
      case 'subuh':
        return const Icon(Icons.wb_twighlight, color: Color(0xFF04700D), size: 26);
      case 'dzuhur':
        return const Icon(Icons.wb_sunny, color: Color(0xFFB68D40), size: 26);
      case 'ashar':
        return const Icon(Icons.wb_cloudy, color: Color(0xFF04700D), size: 26);
      case 'maghrib':
        return const Icon(Icons.nights_stay, color: Color(0xFFB68D40), size: 26);
      case 'isya':
        return const Icon(Icons.nightlight_round, color: Color(0xFF04700D), size: 26);
      default:
        return const Icon(Icons.access_time, color: Color(0xFF04700D), size: 26);
    }
  }

  Widget _iconInfo(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFCAFBDC),
          child: Icon(icon, color: const Color(0xFF04700D)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF04700D), fontFamily: 'Amiri')),
      ],
    );
  }
}
