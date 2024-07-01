import 'package:flutter/material.dart';
import 'package:imageselector/screens/home_page/file_card.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: const Icon(Icons.menu),
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
            onPressed: () {},
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
          children: const [
            Row(
              children: [
                FileCard(),
                FileCard(),
                FileCard(),
                FileCard(),
              ],
            ),
            Row(
              children: [
                FileCard(),
                FileCard(),
                FileCard(),
                FileCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
