import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hafalq/models/surah_model.dart';
import 'widgets/lokasi_dan_tanggal.dart';
import 'widgets/waktu_sholat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Surah> _surahList = [];

  Future<void> loadSurahData() async {
    final String response =
        await rootBundle.loadString('assets/quran-surah-complete.json');
    final data = json.decode(response) as List<dynamic>;
    setState(() {
      _surahList = data.map((json) => Surah.fromJson(json)).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    loadSurahData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 112, 13),
      body: SafeArea(
        child: Column(
          children: [
            const LokasiDanTanggal(),

            // Container isi utama
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 247, 246, 246),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('',
                          style: TextStyle(
                              fontSize: 1, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const WaktuSholatCard(),
                      const SizedBox(height: 15),

                      // Pencarian
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari ayat atau surah...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 243, 246, 248),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Banner Donasi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 202, 251, 218),
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage('assets/banner.jpg'),
                            fit: BoxFit.cover,
                            opacity: 0.15,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Dukung HafalQ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(
                              'Bantu pengembangan aplikasi dengan donasi seikhlasnya.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text('Daftar Surah',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      // List Surah
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _surahList.length,
                        itemBuilder: (context, index) {
                          final surah = _surahList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              leading: CircleAvatar(
                                backgroundColor:
                                    const Color.fromARGB(255, 4, 112, 13),
                                child: Text('${surah.number}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(surah.latin,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(surah.arabic,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Amiri')),
                                ],
                              ),
                              subtitle: Text(
                                  '${surah.type} | ${surah.ayahCount} Ayat'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Navigasi ke detail surah nanti
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
