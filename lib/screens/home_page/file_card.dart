import 'package:flutter/material.dart';

class FileCard extends StatelessWidget {
  const FileCard({super.key});

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
            Text('Review one'),
            SizedBox(height: 10),
            //Button
            Container(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Open"),
            )
          ],
        ),
      ),
    );
  }
}
