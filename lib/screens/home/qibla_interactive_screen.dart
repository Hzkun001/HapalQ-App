import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class QiblaInteractiveScreen extends StatefulWidget {
  const QiblaInteractiveScreen({super.key});

  @override
  State<QiblaInteractiveScreen> createState() => _QiblaInteractiveScreenState();
}

class _QiblaInteractiveScreenState extends State<QiblaInteractiveScreen> {
  double? _direction;
  double? _qiblaDirection;
  String _location = 'Mencari lokasi...';
  bool _locationError = false;

  @override
  void initState() {
    super.initState();
    _getLocationAndQibla();
    FlutterCompass.events?.listen((event) {
      setState(() {
        _direction = event.heading;
      });
    });
  }

  Future<void> _getLocationAndQibla() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _location = 'Layanan lokasi mati'; _locationError = true; });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _location = 'Izin lokasi ditolak'; _locationError = true; });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() { _location = 'Izin lokasi permanen ditolak'; _locationError = true; });
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _location = 'Lat: ${position.latitude.toStringAsFixed(4)}, Long: ${position.longitude.toStringAsFixed(4)}';
        _qiblaDirection = _calculateQiblaDirection(position.latitude, position.longitude);
        _locationError = false;
      });
    } catch (e) {
      setState(() { _location = 'Gagal mendapatkan lokasi'; _locationError = true; });
    }
  }

  // Perhitungan arah kiblat manual (Ka'bah: 21.4225, 39.8262)
  double _calculateQiblaDirection(double lat, double lng) {
    const double kaabaLat = 21.4225;
    const double kaabaLng = 39.8262;
    double phiK = kaabaLat * math.pi / 180.0;
    double lambdaK = kaabaLng * math.pi / 180.0;
    double phi = lat * math.pi / 180.0;
    double lambda = lng * math.pi / 180.0;
    double qibla = math.atan2(
      math.sin(lambdaK - lambda),
      math.cos(phi) * math.tan(phiK) - math.sin(phi) * math.cos(lambdaK - lambda),
    );
    return (qibla * 180.0 / math.pi + 360.0) % 360.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
        backgroundColor: const Color(0xFF04700D),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getLocationAndQibla,
            tooltip: 'Refresh Lokasi',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore, size: 60, color: Color(0xFF04700D)),
              const SizedBox(height: 18),
              Text(
                _location,
                style: TextStyle(fontSize: 15, color: _locationError ? Colors.red : Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              if (_qiblaDirection != null && _direction != null)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Kompas dasar
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                          ),
                        ],
                        border: Border.all(color: Color(0xFF04700D), width: 3),
                      ),
                      child: Center(
                        child: Text('N', style: TextStyle(fontSize: 28, color: Color(0xFF04700D), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Needle arah kiblat
                    Transform.rotate(
                      angle: ((_qiblaDirection! - _direction!) * math.pi / 180),
                      child: Column(
                        children: [
                          Icon(Icons.arrow_upward, size: 80, color: Colors.brown[700]),
                          const Text('Kiblat', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF04700D))),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text('Arahkan HP Anda hingga panah menunjuk ke arah kiblat.',
                  style: TextStyle(fontSize: 15, color: Colors.black54), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
