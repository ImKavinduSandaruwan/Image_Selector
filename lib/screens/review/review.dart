import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:imageselector/services/google_drive_helper.dart';
import 'dart:html' as html;

class Review extends StatefulWidget {
  final String fileName;

  const Review({super.key, required this.fileName});

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  List<Uint8List> _images = [];
  List<String> _imageNames = [];
  List<String> _imageStatuses = [];
  int currentIndex = 0;
  List<List<dynamic>> rows = [];


  @override
  initState() {
    super.initState();
    _loadImageStatuses().then((_) => _fetchImagesFromDrive());
  }

  void _exportToCsv() {
    List<List<dynamic>> rows = [
      ['Image Name', 'Status', 'Link', 'Best Quality', 'Isolate Background', 'Leader Choice'],
    ];

    for (int i = 0; i < _images.length; i++) {
      // Add a new row for each image
      rows.add([
        _imageNames[i], // Image name
        _imageStatuses[i], // Status
        'https://drive.google.com/uc?export=view&id=${_imageNames[i]}', // Link
        _imageStatuses[i] == 'Best Quality' ? 1 : (_imageStatuses[i] == 'Rejected' ? '-' : 0), // Best Quality
        _imageStatuses[i] == 'Isolate Background' ? 1 : (_imageStatuses[i] == 'Rejected' ? '-' : 0), // Isolate Background
        'No Records', // Leader Choice
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Prepare a blob and create an anchor link
    final blob = html.Blob([csv]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'myCsvFile.csv';
    html.document.body?.children.add(anchor);

    // Trigger a click event on the anchor link
    anchor.click();

    // Cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _fetchImagesFromDrive() async {
    if (GoogleDriveHelper.currentUser == null) {
      await GoogleDriveHelper.handleSignIn();
    }
    if (GoogleDriveHelper.currentUser != null) {
      final authHeaders = await GoogleDriveHelper.currentUser!.authHeaders;
      final authenticateClient = AuthenticatedClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // Find the folder with the given name
      final folderList = await driveApi.files.list(q: "name='${widget.fileName}' and mimeType='application/vnd.google-apps.folder' and trashed=false");
      if (folderList.files == null || folderList.files!.isEmpty) {
        throw Exception('Folder not found');
      }
      final folderId = folderList.files!.first.id;

      // Fetch the files in the folder
      final fileList = await driveApi.files.list(q: "'$folderId' in parents");
      for (var file in fileList.files!) {
        if (file.mimeType!.startsWith('image/')) {
          // Download the image data
          final media = await driveApi.files.get(file.id!, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
          final data = await media.stream.toList();
          final bytes = Uint8List.fromList(data.expand((i) => i).toList());
          setState(() {
            _images.add(bytes);
            _imageNames.add(file.id!);
            _imageStatuses.add('Pending'); // Default status
          });
        }
      }
    }
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _images = result.files.map((file) => file.bytes!).toList();
      });
    }
  }

  Future<void> _uploadToDrive(Uint8List image, String imageName, String folderName) async {
    if (GoogleDriveHelper.currentUser == null) {
      await GoogleDriveHelper.handleSignIn();
    }
    if (GoogleDriveHelper.currentUser != null) {
      final authHeaders = await GoogleDriveHelper.currentUser!.authHeaders;
      final authenticateClient = AuthenticatedClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // Find the folder with the given name
      final folderList = await driveApi.files.list(q: "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false");
      if (folderList.files == null || folderList.files!.isEmpty) {
        throw Exception('Folder not found');
      }
      final folderId = folderList.files!.first.id;

      // Create the file
      final driveFile = drive.File()
        ..name = imageName;

      if (folderId != null) {
        driveFile.parents = [folderId!]; // Set the parent folder ID
      }

      final media = drive.Media(Stream.fromIterable([image.buffer.asUint8List()]), image.lengthInBytes);
      final result = await driveApi.files.create(driveFile, uploadMedia: media);

      print('Uploaded image: ${result.id} to folder: $folderName');
    }
  }

  Future<void> _saveImageStatuses() async {
    final box = await Hive.openBox('imageStatuses');
    await box.put('statuses', _imageStatuses);
    await box.put('currentIndex', currentIndex);
  }

  Future<void> _loadImageStatuses() async {
    final box = await Hive.openBox('imageStatuses');
    final loadedStatuses = box.get('statuses');
    final loadedIndex = box.get('currentIndex');
    if (loadedStatuses != null) {
      setState(() {
        _imageStatuses = List<String>.from(loadedStatuses);
        currentIndex = loadedIndex ?? 0;
      });
    }
  }

  void _showReviewSheet() {
    if (currentIndex < _images.length) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Stack(
              children: [
                Image.memory(
                  _images[currentIndex],
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black.withOpacity(0.7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          child: Text('Reject'),
                          onPressed: () {
                            setState(() {
                              _imageStatuses[currentIndex] = 'Rejected'; // Update the status
                            });
                            _saveImageStatuses(); // Save the updated statuses
                            currentIndex++;
                            Navigator.pop(context);
                            _showReviewSheet();
                          },
                        ),
                        ElevatedButton(
                          child: Text('Approve'),
                          onPressed: () {
                            setState(() {
                              _imageStatuses[currentIndex] = 'Approved'; // Update the status
                            });
                            Navigator.pop(context); // Pop the current dialog
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        child: Text('Best Quality'),
                                        onPressed: () {
                                          setState(() {
                                            // Handle Best Quality
                                            _imageStatuses[currentIndex] = 'Best Quality';
                                          });
                                          currentIndex++;
                                          Navigator.pop(context);
                                          _showReviewSheet();
                                        },
                                      ),
                                      ElevatedButton(
                                        child: Text('Isolate Background'),
                                        onPressed: () {
                                          setState(() {
                                            // Handle Isolate Background
                                            _imageStatuses[currentIndex] = 'Isolate Background';
                                          });
                                          currentIndex++;
                                          Navigator.pop(context);
                                          _showReviewSheet();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImages,
        child: const Icon(Icons.upload),
      ),
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_outlined),
        ),
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45),
              ),
              child: Text("John Doe"),
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 80, 0, 0), // position where you want to show the menu on screen
                items: [
                  PopupMenuItem(
                    value: 1,
                    child: GestureDetector(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                      },
                      child: Text("Logout"),
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("Option 2"),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Text("Download CSV"),
                  ),
                ],
              ).then((value) {
                // handle the value returned from the menu
                if (value != null) {
                  print('User selected: $value');
                  if (value == 3) {
                    try {
                      _exportToCsv();
                    } catch (error) {
                      print("Error exporting to CSV: $error");
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
      body: Column(
        children: [
          //gallery review and goto dashboard
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //gallery and review button
                Row(
                  children: [
                    Text(
                      'Gallery - Review',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        _showReviewSheet();
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Start Review',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                //goto dashboard button and save to drive button,
                Row(
                  children: [
                    //save to drive button
                    GestureDetector(
                      onTap: () async {
                        try {
                          for (int i = 0; i < _images.length; i++) {
                            await _uploadToDrive(_images[i], 'image_$i.png', widget.fileName);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Images uploaded to Google Drive'),
                            ),
                          );
                        }catch (error) {
                          print(error);
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Save to Drive',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    //goto dashboard button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Goto Dashboard',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    //leaders choice
                    GestureDetector(
                      onTap: (){},
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Leader\'s Choice',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          // Display the selected images
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                Color borderColor;

                switch (_imageStatuses[index]) {
                  case 'Rejected':
                    borderColor = Colors.red;
                    break;
                  case 'Approved':
                  case 'Best Quality':
                  case 'Isolate Background':
                    borderColor = Colors.green;
                    break;
                  default:
                    borderColor = Colors.grey; // Default border color for pending status
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 2.0),
                  ),
                  child: Image.memory(_images[index], fit: BoxFit.cover),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AuthenticatedClient extends http.BaseClient {
  final http.Client _client = http.Client();
  final Map<String, String> _headers;

  AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
