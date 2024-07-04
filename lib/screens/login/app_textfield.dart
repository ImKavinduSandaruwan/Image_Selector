import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {

  final String hintText;
  final bool obscureText;
  final TextEditingController controller;

  const AppTextField({super.key, required this.hintText, required this.obscureText, required this.controller});

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: width * 0.3, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black45),
          ),
          fillColor: Colors.grey,
          filled: true,
        ),
      ),
    );
  }
}
