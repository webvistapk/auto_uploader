import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class MessageAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const MessageAudioPlayer({Key? key, required this.audioUrl})
      : super(key: key);

  @override
  _MessageAudioPlayerState createState() => _MessageAudioPlayerState();
}

class _MessageAudioPlayerState extends State<MessageAudioPlayer> {
  late AudioPlayer _audioPlayer;

  Stream<Duration> get _positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get _durationStream => _audioPlayer.durationStream;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildProgressBar(Duration position, Duration? duration) {
    final total = duration ?? Duration.zero;
    final value = position.inMilliseconds /
        (total.inMilliseconds == 0 ? 1 : total.inMilliseconds);

    return SliderTheme(
      data: SliderThemeData(
        thumbColor: Colors.blue,
        activeTrackColor: Colors.blue,
        inactiveTrackColor: Colors.grey.shade300,
        overlayColor: Colors.blue.withOpacity(0.2),
        trackHeight: 2,
      ),
      child: Slider(
        value: value.clamp(0.0, 1.0),
        onChanged: (v) {
          final newPosition =
              Duration(milliseconds: (v * total.inMilliseconds).round());
          _audioPlayer.seek(newPosition);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final playing = state?.playing ?? false;
              final processingState = state?.processingState;

              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return const CircularProgressIndicator();
              }

              return IconButton(
                icon: Icon(
                  playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.blue,
                  size: 36,
                ),
                onPressed: () {
                  if (playing) {
                    _audioPlayer.pause();
                  } else {
                    _audioPlayer.play();
                  }
                },
              );
            },
          ),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _positionStream,
              builder: (context, positionSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: _durationStream,
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProgressBar(position, duration),
                        Text(
                          "${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
