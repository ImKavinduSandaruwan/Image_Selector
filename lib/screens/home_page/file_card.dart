import 'package:flutter/material.dart';

import '../review/review.dart';

class FileCard extends StatelessWidget {

  final String fileName;

  const FileCard({super.key, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(20),
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            //image
            Expanded(
              child: Image(
                image: AssetImage('images/folder.png'),
              ),
            ),
            SizedBox(height: 10),
            //file name
            Text(fileName),
            SizedBox(height: 10),
            //Button
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Review(fileName: fileName,)));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text("Open"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
