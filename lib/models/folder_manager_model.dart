import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:imageselector/screens/home_page/file_card.dart';

class FolderManagerModel extends ChangeNotifier {
  List<FileCard> folders = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FolderManagerModel() {
    _loadFoldersFromFirestore();
  }

  void _loadFoldersFromFirestore() async {
    final snapshot = await _firestore.collection('folders').get();
    folders = snapshot.docs.map((doc) => FileCard(fileName: doc['name'])).toList();
    notifyListeners();
  }

  void addFolder(String fileName) async {
    try {
      folders.add(FileCard(fileName: fileName));
      notifyListeners();
      await _firestore.collection('folders').add({'name': fileName});
      print("Folder added successfully: $fileName");
    } catch (e) {
      print("Error adding folder: $e");
    }
  }
}
