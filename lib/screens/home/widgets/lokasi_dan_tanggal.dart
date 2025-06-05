import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LokasiDanTanggal extends StatefulWidget {
  const LokasiDanTanggal({super.key});

  @override
  State<LokasiDanTanggal> createState() => _LokasiDanTanggalState();
}

class _LokasiDanTanggalState extends State<LokasiDanTanggal> {
  late Timer _timer;

  late DateTime dzuhur;
  late DateTime ashar;
  late DateTime maghrib;
  late DateTime isya;
  late DateTime subuh;

  DateTime? nextPrayerTime;
  String? nextPrayerName;

  Duration _countdown = Duration.zero;
  String _lokasi = 'Mencari lokasi...';

  @override
  void initState() {
    super.initState();
    _getLokasiUser();
    _initPrayerTimes();
    _updateNextPrayer();
    _startCountdown();
  }

  Future<void> _getLokasiUser() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _lokasi = 'Layanan lokasi mati';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _lokasi = 'Izin lokasi ditolak';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _lokasi = 'Izin lokasi permanen ditolak';
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _lokasi = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'Lokasi tidak diketahui';
        });
      } else {
        setState(() {
          _lokasi = 'Lokasi tidak ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        _lokasi = 'Gagal mendapatkan lokasi';
      });
    }
  }

  void _initPrayerTimes() {
    final today = DateTime.now();
    dzuhur = DateTime(today.year, today.month, today.day, 12, 10);
    ashar = DateTime(today.year, today.month, today.day, 15, 30);
    maghrib = DateTime(today.year, today.month, today.day, 18, 5);
    isya = DateTime(today.year, today.month, today.day, 19, 20);
    subuh = DateTime(today.year, today.month, today.day, 4, 58);
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    if (nextPrayerTime != null &&
        (now.isAfter(nextPrayerTime!) || now.isAtSameMomentAs(nextPrayerTime!))) {
      _updateNextPrayer();
    }

    setState(() {
      if (nextPrayerTime != null) {
        _countdown = nextPrayerTime!.difference(now);
        if (_countdown.isNegative) _countdown = Duration.zero;
      } else {
        _countdown = Duration.zero;
      }
    });
  }

  void _updateNextPrayer() {
    final now = DateTime.now();

    final List<Map<String, DateTime>> prayers = [
      {'Dzuhur': dzuhur},
      {'Ashar': ashar},
      {'Maghrib': maghrib},
      {'Isya': isya},
      {
        'Subuh': subuh.isAfter(now)
            ? subuh
            : subuh.add(const Duration(days: 1))
      },
    ];

    for (var prayer in prayers) {
      final name = prayer.keys.first;
      final time = prayer.values.first;
      if (time.isAfter(now)) {
        nextPrayerName = name;
        nextPrayerTime = time;
        return;
      }
    }

    nextPrayerName = 'Subuh';
    nextPrayerTime = subuh.add(const Duration(days: 1));
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours Jam $minutes Menit $seconds Detik';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lokasi & Setting
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(_lokasi,
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              const Icon(Icons.settings, color: Colors.white),
            ],
          ),
        ),

        // Tanggal Hijriyah (sementara dummy)
        const Text(
          '30 Dzulqaidah 1446 H',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),

        // Waktu Sholat Berikutnya (nama dan jam)
        Text(
          nextPrayerName != null && nextPrayerTime != null
              ? '$nextPrayerName - ${DateFormat('HH:mm').format(nextPrayerTime!)}'
              : 'Loading...',
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),

        // Countdown
        Text(
          formatDuration(_countdown),
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
