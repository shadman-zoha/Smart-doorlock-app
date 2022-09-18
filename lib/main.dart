import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'FaceDetector.dart';
import 'package:my_face_detection/home.dart';
import 'package:my_face_detection/savedFaces.dart';
import 'package:my_face_detection/unKnownFaces.dart';



void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //use of Firebase service without initialization of Firebase core.

  runApp(MaterialApp(
    themeMode: ThemeMode.dark,
    theme: ThemeData(brightness: Brightness.light),
    title: "Smart Door Lock",
    debugShowCheckedModeBanner: false,

    routes: {
      '/':(context) => Home(),
      '/newUser':(context)=> FaceDetector(),
      '/savedFaces':(context)=> savedFaces(),
      '/unKnownFaces':(context)=> unKnownFaces(),
    },
  ));
}
