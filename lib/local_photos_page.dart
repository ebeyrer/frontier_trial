import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontier_trial/old_photos_page.dart';
import 'package:path_provider/path_provider.dart';

class LocalPhotosScreen extends StatefulWidget {
  const LocalPhotosScreen({super.key});

  @override
  State<LocalPhotosScreen> createState() => _LocalPhotosScreenState();
}

class _LocalPhotosScreenState extends State<LocalPhotosScreen> {
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadLocalPhotos();
  }

  Future<void> _loadLocalPhotos() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      setState(() {
        _imagePaths =
            Directory(appDocPath).listSync().map((file) => file.path).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading local photos: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Photos'),
        actions: [
          //upload button
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () {
              // TODO upload all the photos to Firebase Storage

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OldPhotosPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _imagePaths.isEmpty
          ? const Center(child: Text('No photos found locally'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Image.file(File(_imagePaths[index]));
              },
            ),
    );
  }
}
