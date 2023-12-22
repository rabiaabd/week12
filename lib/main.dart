  /*
This application demonstrates the use of the below topics:
1- Saving passwords in EncryptedSharedPreferences
2- Creating and validating flutter forms
3- Sending JSON object using HTTP POST to a REST API

It will allow the user to enter a key and then stores it in encrypted form.
It then allows the user to enter a category's cid and name and sends them to
the REST API along with the authorization key.
 */
import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'csci410 week 12',
        home: Home());
  }
}
