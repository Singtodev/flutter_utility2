// ignore_for_file: unused_field

import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;
  File? savedFile;

  Future<void> chooseImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _image = image;
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> takeAPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> saveImage() async {
    // final Directory? tempDir = await getDownloadsDirectory();
    var picturesPath = await AndroidPathProvider.picturesPath;
    if (picturesPath != "" && _image != null) {
      savedFile = File('$picturesPath/${_image!.name}');
      _image!.saveTo(savedFile!.path);
      debugPrint(savedFile!.path.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            FilledButton(
                onPressed: () {
                  chooseImage();
                },
                child: const Text("Gallery")),
            FilledButton(
                onPressed: () {
                  takeAPhoto();
                },
                child: const Text("Camera")),
            _image != null
                ? Image.file(File(_image!.path))
                : const Text("กรุณาเลือกรูป"),
            FilledButton(
                onPressed: () {
                  saveImage();
                },
                child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
