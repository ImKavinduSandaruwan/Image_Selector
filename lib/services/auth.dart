import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/home_page/home_page.dart';
import '../screens/login/login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          //user is signed in
          if(snapshot.hasData){
            return HomePage();
          }else{
            return Login();
          }
        },
      ),
    );
  }
}
