import 'package:audioplayers/audioplayers.dart';

class SirenService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;
  static bool _sourceSet = false;

  static Future<void> _prepareSource() async {
    if (_sourceSet) return;
    await _player.setSource(AssetSource('audio/siren.mp3'));
    await _player.setReleaseMode(ReleaseMode.loop);
    _sourceSet = true;
  }

  static Future<void> startSiren() async {
    if (_isPlaying) return;
    await _prepareSource();
    await _player.resume();
    _isPlaying = true;
  }

  static Future<void> stopSiren() async {
    await _player.stop();
    _isPlaying = false;
  }
  
  static bool get isPlaying => _isPlaying;
}
