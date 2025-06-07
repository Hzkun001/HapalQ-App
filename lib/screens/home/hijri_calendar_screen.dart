import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HijriCalendarScreen extends StatelessWidget {
  const HijriCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('id_ID', null); // Pastikan locale Indonesia sudah diinisialisasi

    final now = DateTime.now().toLocal();
    final today = HijriCalendar.fromDate(now);
    final daysInMonth = today.lengthOfMonth;
    final firstDay = HijriCalendar()
      ..hYear = today.hYear
      ..hMonth = today.hMonth
      ..hDay = 1;
    // Nama hari dalam bahasa Arab (Minggu ke Sabtu)
    final weekDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    // final weekDays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']; // versi lama
    final monthName = today.longMonthName;
    final dayName = today.dayWeName;
    final firstWeekday = firstDay.wkDay ?? 7;
    final masehiDesc = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Hijriah'),
        backgroundColor: const Color(0xFF04700D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Text(
              '$monthName ${today.hYear} H',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF04700D), fontFamily: 'Amiri'),
            ),
            const SizedBox(height: 4),
            Text(
              masehiDesc,
              style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Amiri'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFCAFBDC),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((d) => Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF04700D)))).toList(),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: daysInMonth + (firstWeekday - 1),
                itemBuilder: (context, i) {
                  if (i < firstWeekday - 1) {
                    return const SizedBox();
                  }
                  final day = i - (firstWeekday - 2);
                  final isToday = day == today.hDay;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isToday ? const Color(0xFF04700D) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isToday ? const Color(0xFF04700D) : const Color(0xFFCAFBDC), width: 1.2),
                      boxShadow: isToday
                          ? [BoxShadow(color: const Color(0xFF04700D).withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isToday ? Colors.white : const Color(0xFF04700D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hari ini: $dayName, ${today.hDay} $monthName ${today.hYear} H / $masehiDesc',
              style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Amiri'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kalender hijriah mengikuti Ummul Qura (Mekkah) dan waktu lokal Indonesia.',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
