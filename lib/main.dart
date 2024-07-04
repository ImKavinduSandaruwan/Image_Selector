import 'package:flutter/material.dart';
import 'package:imageselector/models/folder_manager_model.dart';
import 'package:imageselector/screens/home_page/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:imageselector/screens/login/login.dart';
import 'package:imageselector/screens/register/register.dart';
import 'package:imageselector/screens/review/review.dart';
import 'package:imageselector/services/auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ImageApp());
}

class ImageApp extends StatelessWidget {
  const ImageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
      },
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => FolderManagerModel(),
        child: HomePage(),
      ),
    );
  }
}

