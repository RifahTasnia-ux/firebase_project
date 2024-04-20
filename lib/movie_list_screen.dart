import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class ImageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Storage')),
      body: ImageGridView(),
    );
  }
}

class ImageGridView extends StatefulWidget {
  @override
  _ImageGridViewState createState() => _ImageGridViewState();
}

class _ImageGridViewState extends State<ImageGridView> {
  List<String> imageURLs = [];
  int imageCount = 0;
  int videoCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            pickImageOrVideoFromGallery();
          },
          child: Text('Pick Images/Videos from Gallery'),
        ),
        SizedBox(height: 10), // Add some space between the button and the count display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Images: $imageCount'),
            SizedBox(width: 20),
            Text('Videos: $videoCount'),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemCount: imageURLs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.all(8.0),
                // Add padding around each GridTile
                child: GridTile(
                  child: Image.network(imageURLs[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> uploadFileToFirebase(File file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('media/$fileName');
      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();
      setState(() {
        imageURLs.add(downloadURL);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File uploaded successfully to Firebase Storage!'),
          duration: Duration(seconds: 2), // Adjust duration as needed
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> pickImageOrVideoFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      await uploadFileToFirebase(file);
      setState(() {
        imageCount++;
      });
    } else {
      final pickedVideo = await picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedVideo != null) {
        File file = File(pickedVideo.path);
        await uploadFileToFirebase(file);
        setState(() {
          videoCount++; // Increment video count when a video is picked
        });
      } else {
        print('No media selected.');
      }
    }
  }
}