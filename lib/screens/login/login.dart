import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:imageselector/screens/login/app_textfield.dart';
import 'package:provider/provider.dart';

import '../../models/folder_manager_model.dart';
import '../home_page/home_page.dart';

class Login extends StatelessWidget {
  Login({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //sign in
  void signIn(BuildContext context) async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
          ChangeNotifierProvider(
            create: (context) => FolderManagerModel(),
            child: HomePage(),
          )
      ));
    }catch(e){
      print('>>>>>>>>>>>>$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Icon(Icons.lock, size: 100),
            SizedBox(height: 20,),

            //welcome back
            Text('Welcome Back', style: TextStyle(fontSize: 30)),
            SizedBox(height: 20,),

            //email textfield
            AppTextField(
              hintText: 'Enter Email',
              obscureText: false,
              controller: emailController
            ),

            SizedBox(height: 10,),

            //password textfield
            AppTextField(
              hintText: 'Enter Password',
              obscureText: true,
              controller: passwordController
            ),
            SizedBox(height: 40,),

            //login button
            GestureDetector(
              onTap: () {
                signIn(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text(
                  "Sign in",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
              ),
            ),

            //already have an account
            SizedBox(height: 20,),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: Text('Don\'t have an account? Register', style: TextStyle(fontSize: 15)),
            )
          ],
        ),
      ),
    );
  }
}
