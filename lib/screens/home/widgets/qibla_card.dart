import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QiblaCard extends StatelessWidget {
  final VoidCallback? onTap;
  const QiblaCard({this.onTap, super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SvgPicture.asset('assets/qibla.svg', height: 40),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Arah Kiblat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}
