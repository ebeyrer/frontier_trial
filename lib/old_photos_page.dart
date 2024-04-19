import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OldPhotosPage extends StatefulWidget {
  const OldPhotosPage({super.key});

  @override
  State<OldPhotosPage> createState() => _OldPhotosPageState();
}

class _OldPhotosPageState extends State<OldPhotosPage> {
  Map<String, String> _imageUrlsAndDates = {};

  Future<Map<String, String>> getImageUrlsFromStorage(String folderName) async {
    Map<String, String> imageUrls = {};
    Reference storageReference =
        FirebaseStorage.instance.ref().child(folderName);
    ListResult result = await storageReference.listAll();
    for (Reference ref in result.items) {
      String url = await ref.getDownloadURL();
      String date = ref.name.split(' ')[0];
      imageUrls[url] = date;
    }
    return imageUrls;
  }

  @override
  void initState() {
    super.initState();
    getImageUrlsFromStorage('images/').then((value) {
      setState(() {
        _imageUrlsAndDates = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Cows'),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/images/cow_head.svg',
              width: 20,
              height: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _imageUrlsAndDates.length,
        itemBuilder: (context, index) {
          String url = _imageUrlsAndDates.keys.elementAt(index);
          String date = _imageUrlsAndDates.values.elementAt(index);
          return SizedBox(
            height: 300,
            width: 200,
            child: Column(
              children: [
                Image.network(
                  url,
                  fit: BoxFit.fitHeight,
                  height: 200,
                ),
                Text(
                  date,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
