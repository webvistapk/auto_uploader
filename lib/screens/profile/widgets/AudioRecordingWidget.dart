
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile/controller/function/AudioController.dart';
import 'package:waveform_recorder/waveform_recorder.dart';




class AudioWidget extends StatefulWidget {
  final AudioController controller;
  final File? audioFile;
  final VoidCallback onDelete;
  final bool showRecordingUI;

  const AudioWidget({
    Key? key,
    required this.controller,
    this.audioFile,
    required this.onDelete,
    required this.showRecordingUI,
  }) : super(key: key);

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.showRecordingUI && widget.controller.isRecording) {
      return _buildRecordingUI();
    } else if (widget.audioFile != null) {
      return _buildAudioPreview();
    }
    return Container();
  }

  Widget _buildRecordingUI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: widget.controller.waveController.isRecording
                ? WaveformRecorder(
                    controller: widget.controller.waveController,
                    height: 40,
                  )
                : const SizedBox(height: 40),
          ),
          const SizedBox(width: 8),
          // Text(
          //   '${widget.controller.recordingDuration}s',
          //   style: const TextStyle(fontSize: 16, color: Colors.black),
          // ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () async {
              await widget.controller.stopRecording();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPreview() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  widget.controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.blue,
                  size: 30,
                ),
                onPressed: () => widget.controller.togglePlayback(widget.audioFile!),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<Duration?>(
                      stream: widget.controller.audioPlayer.positionStream,
                      builder: (context, positionSnapshot) {
                        return StreamBuilder<Duration?>(
                          stream: widget.controller.audioPlayer.durationStream,
                          builder: (context, durationSnapshot) {
                            final position = positionSnapshot.data ?? Duration.zero;
                            Duration duration = durationSnapshot.data ?? Duration.zero;

                            if (duration.inMilliseconds == 0) {
                              duration = Duration(seconds: widget.controller.recordingDuration);
                            }

                            final progress = duration.inMilliseconds > 0
                                ? position.inMilliseconds / duration.inMilliseconds
                                : 0.0;

                            return Column(
                              children: [
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  minHeight: 3,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                onPressed: widget.onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}