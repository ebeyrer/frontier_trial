// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontier_trial/object_painter.dart';
import 'package:frontier_trial/profile_screen.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';

import 'package:path/path.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? imageUrl;
  File? _image;
  dynamic image;
  String? _recognitions;
  late ImagePicker picker;
  late ObjectDetector objectDetector;
  bool? isCow;
//Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
    doObjectDetection();
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
    doObjectDetection();
  }

  // String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
  // Reference referenceRoot = FirebaseStorage.instance.ref();
  // Reference referenceDirImages = referenceRoot.child('images');
  // Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

  // try {
  //   await referenceImageToUpload.putFile(_image!);
  //   imageUrl = await referenceImageToUpload.getDownloadURL();
  // } catch (e) {
  //   print(e);
  // }
  // }
  Future<void> saveImageToFirebase(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      print('No internet connection');
      await saveImageToLocal(context);
      return;
    }
    //make the unique file name with the date and time
    String uniqueFileName =
        '${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year} ${DateTime.now().millisecondsSinceEpoch.toString()}';
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try {
      await referenceImageToUpload.putFile(_image!);
      imageUrl = await referenceImageToUpload.getDownloadURL();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to Firebase'),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveImageToLocal(BuildContext context) async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      String localImagePath = '$appDocPath/$fileName';
      await _image!.copy(localImagePath);
      print('Image saved locally: $localImagePath');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to local folder'),
        ),
      );
    } catch (e) {
      print('Error saving image locally: $e');
    }
  }

  List<DetectedObject> objects = [];
  doObjectDetection() async {
    InputImage inputImage = InputImage.fromFile(_image!);
    objects = await objectDetector.processImage(inputImage);
    if (objects.isEmpty) {
      setState(() {
        _recognitions = 'No object detected';
      });
    }
    isCow = false;

    for (DetectedObject detectedObject in objects) {
      for (Label label in detectedObject.labels) {
        print('${label.text} ${label.confidence}');
        if (label.text.contains('3') && label.confidence > 0.5) {
          isCow = true;
        }
      }
      setState(() {
        isCow;
        if (isCow == true) {
          _recognitions = 'This is a cow';
        } else {
          _recognitions = 'This is not a cow';
        }
      });
    }
    drawRectanglesAroundObjects();
  }

  drawRectanglesAroundObjects() async {
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {
      image;
      objects;
    });
  }

  loadModel() async {
    final modelPath = await getModelPath('assets/moodel_metadata.tflite');
    final options = LocalObjectDetectorOptions(
      mode: DetectionMode.single,
      modelPath: modelPath,
      classifyObjects: true,
      multipleObjects: true,
    );
    objectDetector = ObjectDetector(options: options);
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  @override
  void initState() {
    super.initState();
    picker = ImagePicker();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   title: const Text('Is This a Cow?'),
      //   actions: [
      //     IconButton(
      //         onPressed: () {
      //           // getImageFromCamera();
      //           //navitage to old photos page
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => const ProfileScreen()));
      //         },
      //         icon: const Icon(Icons.person))
      //   ],
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 182, 128, 58),
              Colors.white
            ], // You can change the colors as needed
          ),
        ),
        child: Stack(
          children: <Widget>[
            // Background with an angle
            Positioned.fill(
              child: Transform.rotate(
                angle: -1.7,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 3,
                  color: Colors.white.withOpacity(0.1),

                  // Adjust opacity as needed
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          onPressed: () {
                            // getImageFromCamera();
                            //navitage to old photos page
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen()));
                          },
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.person_2_rounded,
                              size: 40,
                              color: Colors.black,
                            ),
                          ))),
                  Text(
                    _recognitions ?? "",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  _image != null
                      ? Center(
                          child: FittedBox(
                            child: SizedBox(
                              width: image.width.toDouble(),
                              height: image.width.toDouble(),
                              child: CustomPaint(
                                painter: ObjectPainter(
                                    objectList: objects, imageFile: image),
                              ),
                            ),
                          ),
                        )
                      : SvgPicture.asset(
                          'assets/images/cow_head.svg',
                          width: 400,
                          height: 600,
                        ),
                  isCow != null
                      ? ElevatedButton(
                          onPressed: () {
                            if (isCow == true) {
                              saveImageToFirebase(context);
                            } else {
                              setState(() {
                                _image = null;
                                _recognitions = null;
                                isCow = null;
                              });
                            }
                          },
                          child: Text(
                              isCow == true
                                  ? 'Upload Cow Image'
                                  : 'Clear Image',
                              style: const TextStyle(color: Colors.white)))
                      : const Text("Please select an option below"),
                ],
              ),
            ),
          ],
        ),
      ),
      //make a bottom navigation bar with three icons
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Gallery',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            getImageFromCamera();
          } else if (index == 1) {
            getImageFromGallery();
          }
        },
      ),
      // floatingActionButton: GestureDetector(
      //   onLongPress: () => getImageFromCamera(),
      //   child: FloatingActionButton(
      //     onPressed: getImageFromGallery,
      //     tooltip: 'Pick Image',
      //     child: const Icon(Icons.add_a_photo),
      //   ),
      // ),
    );
  }
}
