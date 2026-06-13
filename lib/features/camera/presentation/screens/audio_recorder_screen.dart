import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../utils/camera_constants.dart';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final RecorderController _waveController = RecorderController()
    ..androidEncoder = AndroidEncoder.aac
    ..androidOutputFormat = AndroidOutputFormat.mpeg4
    ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    ..sampleRate = 44100
    ..bitRate = 48000;

  bool _isRecording = false;
  String _recordingTime = "00:00:00";
  String? _recordedPath;
  Timer? _timer;
  DateTime? _startTime;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;
    final dir = await getTemporaryDirectory();
    final path = "${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
    await _recorder.start(const RecordConfig(), path: path);
    await _waveController.record();
    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null && mounted) {
        setState(() {
          _recordingTime = _formatDuration(DateTime.now().difference(_startTime!));
        });
      }
    });
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    await _waveController.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordedPath = path;
      });
    }
  }

  void _discardRecording() {
    _timer?.cancel();
    _recorder.stop();
    _waveController.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordedPath = null;
        _recordingTime = "00:00:00";
        _startTime = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Record Audio',
          style: TextStyle(
            color: Colors.black,
            fontSize: size.width * numD045,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
          if (_isRecording)
            AudioWaveforms(
              size: Size(size.width, 100),
              recorderController: _waveController,
              enableGesture: false,
              backgroundColor: Colors.transparent,
              waveStyle: const WaveStyle(
                waveColor: colorEmployeeGreen1,
                extendWaveform: true,
                showMiddleLine: false,
                showDurationLabel: false,
              ),
            ),
          Text(
            _recordingTime,
            style: TextStyle(
              fontSize: size.width * numD15,
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * numD08,
              vertical: size.width * numD04,
            ),
            child: Row(
              children: [
                if (_recordingTime != "00:00:00")
                  IconButton(
                    onPressed: _discardRecording,
                    icon: Icon(Icons.close,
                        color: Colors.red, size: size.width * numD08),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else if (_recordedPath != null) {
                      Navigator.pop(context, [_recordedPath!, _recordingTime]);
                    } else {
                      _startRecording();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(size.width * numD01),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorEmployeeGreen1),
                    ),
                    child: Icon(
                      _isRecording
                          ? Icons.stop_circle_outlined
                          : _recordedPath != null
                              ? Icons.check_circle
                              : Icons.circle,
                      color: colorEmployeeGreen1,
                      size: size.width * numD13,
                    ),
                  ),
                ),
                const Spacer(),
                if (_recordedPath != null)
                  IconButton(
                    onPressed: () =>
                        Navigator.pop(context, [_recordedPath!, _recordingTime]),
                    icon: Icon(Icons.check,
                        color: const Color(0xFF388E3C), size: size.width * numD08),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
