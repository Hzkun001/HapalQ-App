import 'package:flutter/material.dart';
import 'package:hafalq/models/ayat_model.dart';
import 'package:hafalq/services/quran_api_service.dart';
import 'package:hafalq/models/surah_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hafalq/screens/home/widgets/qibla_card.dart';

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  const SurahDetailScreen({super.key, required this.surah});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  List<Ayat> _ayatList = [];
  bool _isLoading = true;
  final Map<int, AudioPlayer> _audioPlayers = {};
  int? _playingAyat;
  double _playbackSpeed = 1.0;
  AudioPlayer? _fullSurahPlayer;
  bool _isPlayingFullSurah = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadAyat();
  }

  @override
  void dispose() {
    for (var player in _audioPlayers.values) {
      player.dispose();
    }
    _fullSurahPlayer?.dispose();
    super.dispose();
  }

  Future<void> loadAyat() async {
    try {
      final ayatList = await QuranApiService.fetchAyatList(widget.surah.number);
      setState(() {
        _ayatList = ayatList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playAyat(Ayat ayat) async {
    if (ayat.audioUrl == null) return;
    _audioPlayers[ayat.number]?.dispose();
    final player = AudioPlayer();
    _audioPlayers[ayat.number] = player;
    setState(() {
      _playingAyat = ayat.number;
    });
    await player.setUrl(ayat.audioUrl!);
    await player.setSpeed(_playbackSpeed);
    await player.play();
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingAyat = null;
        });
      }
    });
  }

  Future<void> _repeatAyat(Ayat ayat) async {
    if (ayat.audioUrl == null) return;
    _audioPlayers[ayat.number]?.dispose();
    final player = AudioPlayer();
    _audioPlayers[ayat.number] = player;
    setState(() {
      _playingAyat = ayat.number;
    });
    await player.setUrl(ayat.audioUrl!);
    await player.setSpeed(_playbackSpeed);
    await player.setLoopMode(LoopMode.one);
    await player.play();
  }

  void _stopAyat(int ayatNumber) {
    _audioPlayers[ayatNumber]?.stop();
    setState(() {
      _playingAyat = null;
    });
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    for (var player in _audioPlayers.values) {
      player.setSpeed(speed);
    }
    _fullSurahPlayer?.setSpeed(speed);
  }

  Future<void> _playFullSurah() async {
    if (_ayatList.isEmpty) return;
    _fullSurahPlayer?.dispose();
    final player = AudioPlayer();
    _fullSurahPlayer = player;
    setState(() {
      _isPlayingFullSurah = true;
    });
    final playlist = ConcatenatingAudioSource(
      children: _ayatList
          .where((a) => a.audioUrl != null)
          .map((a) => AudioSource.uri(Uri.parse(a.audioUrl!)))
          .toList(),
    );
    await player.setAudioSource(playlist);
    await player.setSpeed(_playbackSpeed);
    await player.play();
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlayingFullSurah = false;
        });
      }
    });
  }

  void _stopFullSurah() {
    _fullSurahPlayer?.stop();
    setState(() {
      _isPlayingFullSurah = false;
    });
  }

  List<Ayat> get _filteredAyatList {
    if (_searchQuery.isEmpty) return _ayatList;
    final q = _searchQuery.toLowerCase();
    return _ayatList.where((a) =>
      a.arabic.contains(_searchQuery) ||
      a.latin.toLowerCase().contains(q) ||
      a.translation.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.latin),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Kembali',
        ),
        backgroundColor: const Color.fromARGB(255, 4, 112, 13),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text('Kecepatan:'),
                      Expanded(
                        child: Slider(
                          value: _playbackSpeed,
                          min: 0.5,
                          max: 2.0,
                          divisions: 6,
                          label: '${_playbackSpeed.toStringAsFixed(1)}x',
                          onChanged: (value) => _setPlaybackSpeed(value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(_isPlayingFullSurah ? Icons.stop_circle : Icons.play_circle_fill, size: 24),
                        label: Text(_isPlayingFullSurah ? 'Stop Surah' : 'Putar Surah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 4, 112, 13),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: _isPlayingFullSurah ? _stopFullSurah : _playFullSurah,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari ayat, latin, atau terjemahan...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: QiblaCard(
                    onTap: () {
                      // TODO: Implementasi navigasi/fitur arah kiblat
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Arah Kiblat'),
                          content: const Text('Fitur arah kiblat coming soon!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Tutup'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _filteredAyatList.isEmpty
                      ? const Center(child: Text('Tidak ditemukan ayat yang cocok.'))
                      : ListView.builder(
                          itemCount: _filteredAyatList.length,
                          itemBuilder: (context, index) {
                            final ayat = _filteredAyatList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 4, 112, 13),
                                  width: 1,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(
                                    ayat.arabic,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Amiri',
                                      color: Color.fromARGB(255, 4, 112, 13),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        ayat.latin,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(255, 4, 112, 13),
                                        ),
                                      ),
                                      Text(
                                        ayat.translation,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (ayat.audioUrl != null && ayat.audioUrl!.isNotEmpty)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(_playingAyat == ayat.number ? Icons.stop_circle : Icons.play_circle_fill, size: 24, color: Colors.green[800]),
                                              tooltip: _playingAyat == ayat.number ? 'Stop' : 'Putar',
                                              onPressed: () {
                                                if (_playingAyat == ayat.number) {
                                                  _stopAyat(ayat.number);
                                                } else {
                                                  _playAyat(ayat);
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.repeat, size: 20, color: Colors.orange),
                                              tooltip: 'Ulang Ayat',
                                              onPressed: () => _repeatAyat(ayat),
                                            ),
                                          ],
                                        ),
                                      if (ayat.audioUrl == null || ayat.audioUrl!.isEmpty)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.play_circle_outline, size: 24, color: Colors.grey),
                                              tooltip: 'Audio tidak tersedia',
                                              onPressed: null,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.repeat, size: 20, color: Colors.grey),
                                              tooltip: 'Audio tidak tersedia',
                                              onPressed: null,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color.fromARGB(255, 4, 112, 13),
                                    child: Text(
                                      '${ayat.number}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
