import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hafalq/models/surah_model.dart';
import 'package:hafalq/services/quran_api_service.dart';
import 'package:hafalq/screens/surah_detail_screen.dart';
import 'widgets/jadwal_sholat_card.dart';
import 'widgets/main_feature_widgets.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  int _selectedIndex = 0;
  List<Surah> _surahList = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMsg;
  late TextEditingController _searchController;

  // Tambahkan list bookmark (persistent di memori, bisa diupgrade ke shared_preferences)
  final List<Surah> _bookmarkedSurah = [];

  void _toggleBookmark(Surah surah) {
    setState(() {
      if (_bookmarkedSurah.any((s) => s.number == surah.number)) {
        _bookmarkedSurah.removeWhere((s) => s.number == surah.number);
      } else {
        _bookmarkedSurah.add(surah);
      }
    });
  }

  bool _isBookmarked(Surah surah) {
    return _bookmarkedSurah.any((s) => s.number == surah.number);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    loadSurahData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> loadSurahData() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final surahList = await QuranApiService.fetchSurahList();
      setState(() {
        _surahList = surahList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Gagal memuat daftar surah. Cek koneksi internet.';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    // Dipanggil saat kembali ke halaman ini
    loadSurahData();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      _HomeMainContent(
        surahList: _surahList,
        searchQuery: _searchQuery,
        onSearch: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        isLoading: _isLoading,
        errorMsg: _errorMsg,
        searchController: _searchController,
        onReload: loadSurahData,
        onBookmark: _toggleBookmark,
        isBookmarked: _isBookmarked,
      ),
      _BookmarkPage(
        bookmarkedSurah: _bookmarkedSurah,
        onBookmark: _toggleBookmark,
        isBookmarked: _isBookmarked,
      ),
      const _JadwalPage(),
      const _ProfilePage(),
    ];
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 4, 112, 13),
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF04700D),
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Bookmark'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Konten utama Home
class _HomeMainContent extends StatelessWidget {
  final List<Surah> surahList;
  final String searchQuery;
  final ValueChanged<String> onSearch;
  final bool isLoading;
  final String? errorMsg;
  final TextEditingController searchController;
  final VoidCallback onReload;
  final void Function(Surah) onBookmark;
  final bool Function(Surah) isBookmarked;
  const _HomeMainContent({
    required this.surahList,
    required this.searchQuery,
    required this.onSearch,
    required this.isLoading,
    required this.errorMsg,
    required this.searchController,
    required this.onReload,
    required this.onBookmark,
    required this.isBookmarked,
  });

  @override
  Widget build(BuildContext context) {
    final filteredSurahList = searchQuery.isEmpty
        ? surahList
        : surahList.where((s) =>
            s.latin.toLowerCase().contains(searchQuery.toLowerCase()) ||
            s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            s.arabic.contains(searchQuery)
          ).toList();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF04700D), Color(0xFFCAFBDC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Islamic dengan ornamen SVG dan glassmorphism
          Stack(
            children: [
              // Ornamen SVG besar di background kanan atas
              Positioned(
                right: -30,
                top: -30,
                child: Opacity(
                  opacity: 0.10,
                  child: SizedBox(
                    width: 200,
                    height: 140,
                    child: Image.asset('assets/qibla.svg', fit: BoxFit.contain),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18, left: 0, right: 0, bottom: 0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xCC04700D),
                            const Color(0x99CAFBDC),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x2204700D),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFB68D40), width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Assalamu’alaikum',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Amiri',
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Selamat datang di HafalQ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Amiri',
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _InfoCard(
                                  title: 'Surah',
                                  value: surahList.length.toString(),
                                  icon: Icons.menu_book,
                                  color: const Color(0xFF04700D),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InfoCard(
                                  title: 'Ayat',
                                  value: surahList.fold<int>(0, (a, b) => a + b.ayahCount).toString(),
                                  icon: Icons.format_list_numbered,
                                  color: const Color(0xFFB68D40),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _InfoCard(
                                  title: 'Juz',
                                  value: '30',
                                  icon: Icons.layers,
                                  color: const Color(0xFF04700D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          // Widget utama: Qibla, Jadwal Sholat, Hijriah, Lokasi
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                QiblaWidget(),
                                const SizedBox(width: 10),
                                JadwalSholatWidget(),
                                const SizedBox(width: 10),
                                HijriDateWidget(),
                                const SizedBox(width: 10),
                                LocationWidget(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Quick Action
                        ], // Tutup children Column
                      ), // Tutup Column
                    ), // Tutup Container
                  ), // Tutup ClipRRect
                ), // Tutup Padding
              ), // Tutup Stack
            ], // Tutup children Stack
          ), // Tutup Stack
          const SizedBox(height: 14),
          // Pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari surah atau ayat...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: Color(0xFF04700D), width: 1.2),
                ),
                filled: true,
                fillColor: const Color.fromARGB(255, 243, 246, 248),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: onSearch,
              controller: searchController,
              style: const TextStyle(fontSize: 16, fontFamily: 'Amiri'),
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (errorMsg != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    onPressed: onReload,
                  ),
                ],
              ),
            )
          else if (filteredSurahList.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Tidak ditemukan surah yang cocok.'),
                  TextButton(
                    onPressed: () {
                      searchController.clear();
                      onSearch('');
                    },
                    child: const Text('Reset Pencarian'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredSurahList.length,
              separatorBuilder: (context, idx) => const Divider(indent: 24, endIndent: 24, color: Color(0xFFB6E388), height: 8),
              itemBuilder: (context, index) {
                final surah = filteredSurahList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFF04700D), width: 0.7),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF04700D),
                      radius: 22,
                      child: Text(
                        '${surah.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          surah.latin,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Amiri'),
                        ),
                        Text(
                          surah.arabic,
                          style: const TextStyle(fontSize: 24, fontFamily: 'Amiri', color: Color(0xFF04700D)),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${surah.type} | ${surah.ayahCount} Ayat',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFB68D40)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isBookmarked(surah) ? Icons.bookmark : Icons.bookmark_border,
                            color: const Color(0xFFB68D40),
                          ),
                          tooltip: isBookmarked(surah) ? 'Hapus Bookmark' : 'Bookmark',
                          onPressed: () => onBookmark(surah),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFFB68D40)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(surah: surah),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BookmarkPage extends StatelessWidget {
  final List<Surah> bookmarkedSurah;
  final void Function(Surah) onBookmark;
  final bool Function(Surah) isBookmarked;
  const _BookmarkPage({
    required this.bookmarkedSurah,
    required this.onBookmark,
    required this.isBookmarked,
  });
  @override
  Widget build(BuildContext context) {
    if (bookmarkedSurah.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bookmark, size: 60, color: Color(0xFF04700D)),
            SizedBox(height: 16),
            Text('Belum ada bookmark', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: bookmarkedSurah.length,
      separatorBuilder: (context, idx) => const Divider(indent: 24, endIndent: 24, color: Color(0xFFB6E388), height: 8),
      itemBuilder: (context, index) {
        final surah = bookmarkedSurah[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF04700D), width: 0.7),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF04700D),
              radius: 22,
              child: Text(
                '${surah.number}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                  fontSize: 18,
                ),
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  surah.latin,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Amiri'),
                ),
                Text(
                  surah.arabic,
                  style: const TextStyle(fontSize: 24, fontFamily: 'Amiri', color: Color(0xFF04700D)),
                ),
              ],
            ),
            subtitle: Text(
              '${surah.type} | ${surah.ayahCount} Ayat',
              style: const TextStyle(fontSize: 13, color: Color(0xFFB68D40)),
            ),
            trailing: IconButton(
              icon: Icon(
                isBookmarked(surah) ? Icons.bookmark : Icons.bookmark_border,
                size: 18,
                color: const Color(0xFFB68D40),
              ),
              onPressed: () => onBookmark(surah),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SurahDetailScreen(surah: surah),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _JadwalPage extends StatefulWidget {
  const _JadwalPage();
  @override
  State<_JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<_JadwalPage> {
  Map<String, String>? jadwal;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    setState(() { isLoading = true; errorMsg = null; });
    try {
      // Dummy data, ganti dengan fetch API jika sudah ada
      await Future.delayed(const Duration(milliseconds: 600));
      jadwal = {
        'Subuh': '04:58',
        'Dzuhur': '12:20',
        'Ashar': '15:42',
        'Maghrib': '18:17',
        'Isya': '19:31',
      };
      setState(() { isLoading = false; });
    } catch (e) {
      setState(() { isLoading = false; errorMsg = 'Gagal memuat jadwal sholat.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
        ? const CircularProgressIndicator()
        : errorMsg != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  onPressed: fetchJadwal,
                ),
              ],
            )
          : JadwalSholatCard(jadwal: jadwal!),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF04700D);
    final Color accent = const Color(0xFFCAFBDC);
    return Stack(
      children: [
        // Background gradient + ornament
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF04700D), Color(0xFFCAFBDC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -60,
          child: Opacity(
            opacity: 0.10,
            child: Image.asset('assets/ornament.jpg', width: 220, height: 220, fit: BoxFit.cover),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Glassmorphism Card
                Container(
                  width: 340,
                  margin: const EdgeInsets.only(bottom: 28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: accent.withOpacity(0.18), width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: accent,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.person, size: 60, color: primary),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.verified, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('Nama Pengguna', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary, fontFamily: 'Amiri', letterSpacing: 0.2)),
                        const SizedBox(height: 4),
                        Text('user@email.com', style: TextStyle(fontSize: 15, color: Colors.black54, fontFamily: 'Amiri')),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _profileActionButton(icon: Icons.edit, label: 'Edit Profil', onTap: () {}),
                            const SizedBox(width: 18),
                            _profileActionButton(icon: Icons.settings, label: 'Pengaturan', onTap: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // About & Social
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: primary, size: 22),
                          const SizedBox(width: 8),
                          const Text('Tentang HafalQ', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF04700D), fontFamily: 'Amiri')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'HafalQ adalah aplikasi modern untuk membantu menghafal Al-Qur’an, menampilkan jadwal sholat, arah kiblat, kalender hijriah, dan fitur islami lainnya. Dibuat dengan cinta untuk umat Islam Indonesia.\n\nVersi: 1.0.0\n© 2025 HafalQ Team',
                          style: TextStyle(fontSize: 15, color: Colors.black87, fontFamily: 'Amiri'),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Icon(Icons.alternate_email, color: primary, size: 22),
                          const SizedBox(width: 8),
                          const Text('Kontak & Sosial Media', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF04700D), fontFamily: 'Amiri')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _iconSocial(Icons.email, 'Email', 'hz.sans2298@gmail.com'),
                          const SizedBox(width: 18),
                          _iconSocial(Icons.telegram, 'Telegram', '@hafalqapp'),
                          const SizedBox(width: 18),
                          _iconSocial(Icons.web, 'Website', 'hafalq.com'),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Keluar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFCAFBDC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF04700D).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF04700D), size: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF04700D), fontFamily: 'Amiri')),
          ],
        ),
      ),
    );
  }

  Widget _iconSocial(IconData icon, String label, String value) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF04700D),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF04700D), fontFamily: 'Amiri')),
        Text(value, style: const TextStyle(fontSize: 12, color: Colors.black54, fontFamily: 'Amiri')),
      ],
    );
  }
}

// Tambahkan widget info card, quick action, dan bottom bar di bawah:

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    // Cek apakah value bisa diubah ke int, jika tidak tetap tampilkan value biasa
    final int? intValue = int.tryParse(value);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 7),
          intValue != null
              ? TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: intValue.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  builder: (context, val, child) => Text(
                    val.toInt().toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color, fontFamily: 'Amiri'),
                  ),
                )
              : Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color, fontFamily: 'Amiri')),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'Amiri')),
        ],
      ),
    );
  }
}
