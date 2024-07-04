import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imageselector/services/google_drive_helper.dart';
import 'package:provider/provider.dart';
import 'package:imageselector/models/folder_manager_model.dart';
import 'package:googleapis/drive/v3.dart' as drive;


import '../review/review.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final folderModel = Provider.of<FolderManagerModel>(context);
    final user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;
    final String? name = email?.split('@').first;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (GoogleDriveHelper.currentUser == null) {
            await GoogleDriveHelper.handleSignIn();
          }
          if (GoogleDriveHelper.currentUser != null) {
            final authHeaders = await GoogleDriveHelper.currentUser!.authHeaders;
            final authenticateClient = AuthenticatedClient(authHeaders);
            final driveApi = drive.DriveApi(authenticateClient);

            // Check if parent folder "Collected Images" exists
            final parentFolderList = await driveApi.files.list(q: "name='Collected Images' and mimeType='application/vnd.google-apps.folder' and trashed=false");
            String? parentFolderId;

            if (parentFolderList.files != null && parentFolderList.files!.isNotEmpty) {
              // If it exists, use its ID
              parentFolderId = parentFolderList.files!.first.id;
            } else {
              // If it doesn't exist, create it
              final parentFolderToCreate = drive.File()
                ..name = "Collected Images"
                ..mimeType = "application/vnd.google-apps.folder";

              final parentFolder = await driveApi.files.create(parentFolderToCreate);
              parentFolderId = parentFolder.id;
              print('Created parent folder: ${parentFolder.id}');
            }

            // Create child folder
            final childFolderToCreate = drive.File()
              ..name = "Review ${Random().nextInt(100)}"
              ..mimeType = "application/vnd.google-apps.folder";

            if (parentFolderId != null) {
              childFolderToCreate.parents = [parentFolderId]; // Set parent folder ID
            }

            final childFolder = await driveApi.files.create(childFolderToCreate);
            print('Created child folder: ${childFolder.id} under parent folder: ${parentFolderId}');

            folderModel.addFolder(childFolder.name!);
          }
        },
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {},
          child: Icon(Icons.menu),
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45),
              ),
              child: Text(name ?? 'User'),
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 1,
                    child: Text("Logout"),
                  ),
                  PopupMenuItem(
                      value: 2,
                      child: Text("Connect Google Drive")
                  ),
                ],
              ).then((value) async {
                if (value != null) {
                  print('User selected: $value');
                  if (value == 1) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }else if(value == 2){
                    if (GoogleDriveHelper.currentUser == null) {
                      await GoogleDriveHelper.handleSignIn();
                    }
                  }
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Row(
              children: folderModel.folders,
            ),
          ],
        ),
      ),
    );
  }
}
