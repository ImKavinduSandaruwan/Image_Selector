import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imageselector/screens/home_page/home_page.dart';
import 'package:provider/provider.dart';

import '../../models/folder_manager_model.dart';
import '../login/app_textfield.dart';

class Register extends StatelessWidget {
  Register({super.key});

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //sign in
  void signUp(BuildContext context) async{

    if(passwordController.text == confirmPasswordController.text){
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
        //shaggy@123
        //shaggy@gmail.com
        print('>>>>>>>>>>>>' + e.toString());
      }
    }else{
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
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
            Text('Lets Create an Account', style: TextStyle(fontSize: 30)),
            SizedBox(height: 20,),

            //name
            AppTextField(
                hintText: 'Enter Username',
                obscureText: false,
                controller: usernameController
            ),

            SizedBox(height: 10,),

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
            SizedBox(height: 10,),

            //confirm password textfield
            AppTextField(
                hintText: 'Confirm Password',
                obscureText: false,
                controller: confirmPasswordController
            ),

            SizedBox(height: 40,),

            //login button
            GestureDetector(
              onTap: () {
                signUp(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Text(
                  "Sign Up",
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
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Already have an account? Login', style: TextStyle(fontSize: 15)),
            )
          ],
        ),
      ),
    );
  }
}
