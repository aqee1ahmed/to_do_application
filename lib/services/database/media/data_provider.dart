import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class MediaProvider {
  static final _storage = FirebaseStorage.instance;

  static Future<String> uploadImage(File file, int name) async {
    final ref = _storage.ref("images/$name");
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {
      debugPrint("Hello world");
    });
    return await snapshot.ref.getDownloadURL();
  }
}
