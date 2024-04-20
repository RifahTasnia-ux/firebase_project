import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

Future<void> uploadImageToFirebase(File imageFile) async {
  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child('images/$fileName');
    await ref.putFile(imageFile);
    print('Image uploaded to Firebase Storage.');
  } catch (e) {
    print(e.toString());
  }
}

Future<void> pickImageFromGallery() async {
  final picker = ImagePicker();
  final pickedFile = await picker.getImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);
    await uploadImageToFirebase(imageFile);
  } else {
    print('No image selected.');
  }
}
