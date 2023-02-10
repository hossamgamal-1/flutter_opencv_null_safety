import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:opencv/opencv.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              String? path = await getImage();

              if (path != null) {
                File imageFile = await processImage(path);
                // ignore: use_build_context_synchronously
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(imageFile),
                          // image: FileImage(File(path)),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('print')),
      ),
    );
  }
}

Future<String?> getImage() async =>
    (await ImagePicker().pickImage(source: ImageSource.gallery))?.path;

Future<File> processImage(String path) async {
  File file = File(path);

  var blackAndWhiteEffect = await ImgProc.cvtColor(
      File(path).readAsBytesSync(), ImgProc.colorBGR2GRAY);
  file.writeAsBytesSync(blackAndWhiteEffect);

  var erodeEffect = await ImgProc.erode(file.readAsBytesSync(), [2, 2]);
  file.writeAsBytesSync(erodeEffect);

  var drawCirclesEffect = await ImgProc.houghCircles(
    file.readAsBytesSync(),
    method: ImgProc.houghGradient,
    dp: 1,
    minDist: 20,
    param1: 50,
    param2: 30,
    minRadius: 5,
    maxRadius: 50,
    centerWidth: 3,
    circleWidth: 10,
  );
  file.writeAsBytesSync(drawCirclesEffect);

  return File(file.path);
}
