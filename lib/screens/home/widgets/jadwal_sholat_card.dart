import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class JadwalSholatCard extends StatelessWidget {
  final Map<String, String> jadwal;
  const JadwalSholatCard({required this.jadwal, super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        color: Colors.white.withOpacity(0.97),
        shadowColor: const Color(0xFF04700D).withOpacity(0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/jadwal.svg', height: 38, color: const Color(0xFF04700D).withOpacity(0.85)),
                  const SizedBox(width: 14),
                  const Text(
                    'Jadwal Sholat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Amiri',
                      color: Color(0xFF04700D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...jadwal.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Amiri',
                        color: Color(0xFF04700D),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCAFBDC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Color(0xFF04700D).withOpacity(0.13)),
                      ),
                      child: Text(
                        e.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Amiri',
                          color: Color(0xFF04700D),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
