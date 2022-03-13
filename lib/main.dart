import 'package:flutter/material.dart';
import 'package:record/record.dart';
import "package:simple_permissions/simple_permissions.dart" show Permission, PermissionStatus, SimplePermissions;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Durio Recorder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final fileClass = <String> ['70', '75', '80', '85', '90', '95', '100'];
  DateTime currentPhoneDate = DateTime.now();
  bool _isRecording = false;


  String ? currentFilePath;
  String ? statusText;
  final _audioRecorder  = Record();

  @override
  void initState() {
    _isRecording = false;
    super.initState();
  }

  void startRecording() async {
    try {
      PermissionStatus permissionResult = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);

      if (permissionResult == PermissionStatus.authorized) {
        if (await _audioRecorder.hasPermission()) {
          await _audioRecorder.start();

          bool isRecording = await _audioRecorder.isRecording();
          setState(() {
            _isRecording = isRecording;
            statusText = 'Listening ...';
          });
        }
      }
    } catch (e) {
      setState(() {
        statusText = "Cannot start recording with this error: $e";
      });
    }
  }

  Future <void> stopRecording() async {
    if (_isRecording) {
      currentFilePath = await _audioRecorder.stop();
      // await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        statusText = "Stop recording waiting for saving the record";
        });
    }
  }

  Future <void> changeFileNameOnly(File file, String newFileName) async {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    file.rename(newPath);
  }

  Future <void> saveRecord(buttonClass) async {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    if (_isRecording) {
      await stopRecording();
    }
    try {
      File recordFile = File(currentFilePath!);
      DateTime now = DateTime.now();
      String dir = path.dirname(recordFile.path);
      String formatted = formatter.format(now);

      setState(() {
        String newFilename = formatted + "__" + buttonClass + ".m4a";
        String newPath = path.join(dir, newFilename);
        recordFile.renameSync(newPath);
        currentFilePath = newPath;
        statusText = "Saved file at $currentFilePath";
        });
    } catch (e) {
      setState(() {
        statusText = "Cannot saved file : $currentFilePath with error: $e";
      });
    }
  }

  void removeFile() {
    try {
      File recordFile = File(currentFilePath!);
      recordFile.delete();
      setState(() {
        statusText = "removed file : $currentFilePath";
      });
      currentFilePath = null;
    } catch (e) {
      setState(() {
        statusText = "Cannot remove file : $currentFilePath with this error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              color: currentFilePath == null ? Colors.grey : Colors.red,
              iconSize: 25,
              onPressed: () {
                setState(() {
                  removeFile();
                });
              },
            ),

            Text(_isRecording ? "Recording" : "Ready"),
            IconButton(
              icon: const Icon(Icons.mic),
              color: _isRecording ? Colors.red : Colors.blue,
              iconSize: 150,
              onPressed: () {
                setState(() {
                  if (_isRecording) {
                    stopRecording();
                  } else {
                    startRecording();
                  }
                });
              },
            ),
            Row(
              children: [
                FlatButton(
                  child: Text(fileClass[0]),
                  onPressed: () {
                    saveRecord(fileClass[0]);
                  },
                  color: Colors.red,
                ),
                FlatButton(
                  child: Text(fileClass[1]),
                  onPressed: () {
                    saveRecord(fileClass[1]);
                  },
                  color: Colors.orange,
                ),
                FlatButton(
                  child: Text(fileClass[2]),
                  onPressed: () {
                    saveRecord(fileClass[2]);
                  },
                  color: Colors.yellow,
                ),
              ],
            ),
            Row(
              children: [
                FlatButton(
                  child: Text(fileClass[3]),
                  onPressed: () {
                    saveRecord(fileClass[3]);
                  },
                  color: Colors.lime,
                ),
                FlatButton(
                  child: Text(fileClass[4]),
                  onPressed: () {
                    saveRecord(fileClass[4]);
                  },
                  color: Colors.lightGreen,
                ),
                FlatButton(
                  child: Text(fileClass[5]),
                  onPressed: () {
                    saveRecord(fileClass[5]);
                  },
                  color: Colors.green,
                ),
              ],
            ),

            FlatButton(
              child: Text(fileClass[6]),
              onPressed: () {
              saveRecord(fileClass[6]);
              },
              color: Colors.brown,
            ),
            Text(statusText ?? ""),
          ],
        ),
      ),
    );
  }
}
