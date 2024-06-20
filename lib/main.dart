import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:just_audio/just_audio.dart' as ja;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Recorder Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AudioRecorderPage(),
    );
  }
}

class AudioRecorderPage extends StatefulWidget {
  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  final player = ja.AudioPlayer();

  bool isRecording = false;
  bool? isPlaying;
  String? recordFilePath;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      // Handle the case where the user denies the permission
      // Show a dialog or navigate back
    }
  }

  Future<void> configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await session.setActive(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (recordFilePath != null)
              MaterialButton(
                onPressed: () async {
                  if (audioPlayer.playing) {
                    audioPlayer.stop();
                    setState(() {
                      isPlaying = false;
                    });
                  } else {
                    await audioPlayer.setFilePath(recordFilePath!);
                    await configureAudioSession();
                    audioPlayer.play();
                    setState(() {
                      isPlaying = true;
                    });
                  }
                },
                child: Text(recordFilePath!),
              ),
            if (recordFilePath == null) const Text('JAJAJA POBRE DIABLO'),
            FloatingActionButton(
              onPressed: () async {
                if (isRecording) {
                  await audioRecorder.stop();
                  setState(() {
                    isRecording = false;
                  });
                } else {
                  await _initPermissions();
                  final Directory appDocDir =
                      await getApplicationDocumentsDirectory();
                  final String filePath = p.join(appDocDir.path, 'test.caf');
                  try {
                    await audioRecorder.start(
                      const RecordConfig(
                        encoder: AudioEncoder
                            .aacLc, // Specifying the encoder directly
                        bitRate: 128000, // Bit rate
                        sampleRate: 44100, // Sample rate as before
                        numChannels: 2, // Number of audio channels
                        // Include other parameters as needed
                      ),
                      path: filePath,
                    );
                  } on PlatformException catch (e) {
                    print("Failed to start recording: ${e.message}");
                  }

                  setState(() {
                    isRecording = true;
                    recordFilePath = filePath;
                  });
                }
              },
              child: Icon(isRecording == false ? Icons.mic : Icons.stop),
            )
          ],
        ),
      ),
    );
  }
}
