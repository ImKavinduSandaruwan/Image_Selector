import 'package:flutter/material.dart';
import 'package:imageselector/screens/home_page/file_card.dart';
import '../screens/review/review.dart';
import '../services/google_drive_helper.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class FolderManagerModel extends ChangeNotifier {
  List<FileCard> folders = [];

  FolderManagerModel() {
    _loadFoldersFromDrive();
  }

  void addFolder(String folderName) {
    folders.add(FileCard(fileName: folderName));
    notifyListeners();
  }

  void _loadFoldersFromDrive() async {
    if (GoogleDriveHelper.currentUser == null) {
      await GoogleDriveHelper.handleSignIn();
    }
    if (GoogleDriveHelper.currentUser != null) {
      final authHeaders = await GoogleDriveHelper.currentUser!.authHeaders;
      final authenticateClient = AuthenticatedClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // Find the parent folder with the given name
      final parentFolderList = await driveApi.files.list(q: "name='Collected Images' and mimeType='application/vnd.google-apps.folder' and trashed=false");
      if (parentFolderList.files == null || parentFolderList.files!.isEmpty) {
        throw Exception('Parent folder not found');
      }
      final parentFolderId = parentFolderList.files!.first.id;

      // Fetch the child folders in the parent folder
      final childFolderList = await driveApi.files.list(q: "'$parentFolderId' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false");
      folders = childFolderList.files!.map((file) => FileCard(fileName: file.name!)).toList();
      notifyListeners();
    }
  }
}
