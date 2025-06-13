import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

class AudioController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final WaveformRecorderController _waveController = WaveformRecorderController();
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  bool _isPlaying = false;
  bool _isRecording = false;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  AudioPlayer get audioPlayer => _audioPlayer;
  WaveformRecorderController get waveController => _waveController;
  int get recordingDuration => _recordingDuration;
  bool get isPlaying => _isPlaying;
  bool get isRecording => _isRecording;

  Future<void> init() async {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing && state.processingState == ProcessingState.ready;
    });
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    await _audioPlayer.stop();
    _isPlaying = false;
    _recordingDuration = 0;
    _isRecording = true;

    try {
      // Add small delay to ensure UI is ready
      await Future.delayed(const Duration(milliseconds: 10));
      await _waveController.startRecording();
      _startRecordingTimer();
    } catch (e) {
      _isRecording = false;
      debugPrint('Recording start error: $e');
      rethrow;
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration++;
    });
  }

  Future<File?> stopRecording() async {
    if (!_isRecording) return null;

    _recordingTimer?.cancel();
    _isRecording = false;

    try {
      await _waveController.stopRecording();
      final fileUrl = _waveController.url;
      return fileUrl != null ? File(fileUrl.path) : null;
    } catch (e) {
      debugPrint('Recording stop error: $e');
      rethrow;
    } finally {
      _recordingDuration = 0;
    }
  }

  Future<void> togglePlayback(File audioFile) async {
    if (!await audioFile.exists()) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.file(audioFile.path)),
        );
        await _audioPlayer.play();
        _isPlaying = true;
      }
    } catch (e) {
      _isPlaying = false;
      rethrow;
    }
  }

  Future<void> dispose() async {
    await stopRecording();
    _recordingTimer?.cancel();
    await _playerStateSubscription?.cancel();
    await _audioPlayer.dispose();
     _waveController.dispose();
  }
}