import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hafalq/screens/home/qibla_interactive_screen.dart';
import 'package:hafalq/screens/home/jadwal_sholat_screen.dart';
import 'package:hafalq/screens/home/hijri_calendar_screen.dart';

// Qibla Widget
class QiblaWidget extends StatelessWidget {
  const QiblaWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QiblaInteractiveScreen()),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore, color: Color(0xFF04700D), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Arah Kiblat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Kompas', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Jadwal Sholat Widget (dummy, bisa diisi data nyata via provider/param)
class JadwalSholatWidget extends StatelessWidget {
  const JadwalSholatWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JadwalSholatScreen()),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, color: Color(0xFF04700D), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Jadwal Sholat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Hari ini', style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Hijri Date Widget
class HijriDateWidget extends StatelessWidget {
  const HijriDateWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.now();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HijriCalendarScreen()),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month, color: Color(0xFF04700D), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tanggal Hijriah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} H', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Location Widget
class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});
  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String _lokasi = 'Mencari lokasi...';
  @override
  void initState() {
    super.initState();
    _getLokasiUser();
  }
  Future<void> _getLokasiUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() { _lokasi = 'Layanan lokasi mati'; });
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() { _lokasi = 'Izin lokasi ditolak'; });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() { _lokasi = 'Izin lokasi permanen ditolak'; });
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _lokasi = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'Lokasi tidak diketahui';
        });
      } else {
        setState(() { _lokasi = 'Lokasi tidak ditemukan'; });
      }
    } catch (e) {
      setState(() { _lokasi = 'Gagal mendapatkan lokasi'; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: Color(0xFF04700D), size: 28),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(_lokasi, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
