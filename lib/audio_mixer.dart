import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMixerProvider extends ChangeNotifier {
  final AudioPlayer _lofiPlayer = AudioPlayer();
  final AudioPlayer _chuvaPlayer = AudioPlayer();
  final AudioPlayer _cafePlayer = AudioPlayer();
  final AudioPlayer _brisaPlayer = AudioPlayer();

  bool lofiTocando = false;
  double volumeChuva = 0.65; // 65% como no Figma
  double volumeCafe = 0.32;  // 32% como no Figma
  double volumeBrisa = 0.0;  // 0% (inativa) como no Figma

  AudioMixerProvider() {
    _inicializarPlayers();
  }

  Future<void> _inicializarPlayers() async {
    try {
      await _lofiPlayer.setLoopMode(LoopMode.one);
      await _chuvaPlayer.setLoopMode(LoopMode.one);
      await _cafePlayer.setLoopMode(LoopMode.one);
      await _brisaPlayer.setLoopMode(LoopMode.one);

      // URLs leves de ambiente (substituíveis por AudioSource.asset('assets/audio/...') para 100% offline)
      await _lofiPlayer.setUrl('https://cdn.pixabay.com/download/audio/2022/05/27/audio_1808fbf07a.mp3');
      await _chuvaPlayer.setUrl('https://cdn.pixabay.com/download/audio/2022/03/15/audio_c8c8a73467.mp3');
      await _cafePlayer.setUrl('https://cdn.pixabay.com/download/audio/2022/03/10/audio_c8c8a73467.mp3');
      await _brisaPlayer.setUrl('https://cdn.pixabay.com/download/audio/2021/09/06/audio_884fe92c21.mp3');

      await _chuvaPlayer.setVolume(volumeChuva);
      await _cafePlayer.setVolume(volumeCafe);
      await _brisaPlayer.setVolume(volumeBrisa);
    } catch (_) {
      // Silencia falha caso o dispositivo esteja sem internet inicial
    }
  }

  Future<void> alternarLofi() async {
    lofiTocando = !lofiTocando;
    notifyListeners();
    if (lofiTocando) {
      await _lofiPlayer.play();
    } else {
      await _lofiPlayer.pause();
    }
  }

  Future<void> ajustarChuva(double valor) async {
    volumeChuva = valor;
    notifyListeners();
    await _chuvaPlayer.setVolume(valor);
    if (valor > 0 && !_chuvaPlayer.playing) {
      await _chuvaPlayer.play();
    } else if (valor == 0 && _chuvaPlayer.playing) {
      await _chuvaPlayer.pause();
    }
  }

  Future<void> ajustarCafe(double valor) async {
    volumeCafe = valor;
    notifyListeners();
    await _cafePlayer.setVolume(valor);
    if (valor > 0 && !_cafePlayer.playing) {
      await _cafePlayer.play();
    } else if (valor == 0 && _cafePlayer.playing) {
      await _cafePlayer.pause();
    }
  }

  Future<void> ajustarBrisa(double valor) async {
    volumeBrisa = valor;
    notifyListeners();
    await _brisaPlayer.setVolume(valor);
    if (valor > 0 && !_brisaPlayer.playing) {
      await _brisaPlayer.play();
    } else if (valor == 0 && _brisaPlayer.playing) {
      await _brisaPlayer.pause();
    }
  }

  @override
  void dispose() {
    _lofiPlayer.dispose();
    _chuvaPlayer.dispose();
    _cafePlayer.dispose();
    _brisaPlayer.dispose();
    super.dispose();
  }
}