import 'package:flutter/material.dart';
import '../../../models/surah_model.dart';

class ListSurah extends StatelessWidget {
  final List<Surah> surahList;
  final void Function(Surah) onTap;

  const ListSurah({super.key, required this.surahList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: surahList.length,
      itemBuilder: (context, index) {
        final surah = surahList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            leading: CircleAvatar(
              backgroundColor: const Color.fromARGB(255, 3, 155, 197),
              child: Text('${surah.number}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(surah.latin,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(surah.arabic,
                    style: const TextStyle(
                        fontSize: 20, fontFamily: 'Amiri')),
              ],
            ),
            subtitle:
                Text('${surah.type} | ${surah.ayahCount} Ayat'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => onTap(surah),
          ),
        );
      },
    );
  }
}
