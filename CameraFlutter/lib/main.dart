import 'package:advanced_splashscreen/advanced_splashscreen.dart';
import 'package:dashcam_flutter/mainmenu.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
} 


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        title: "Dash Cam App",
        home: AdvancedSplashScreen(
          child: MainMenu(
          ),
          seconds: 1,
          colorList: [Color(0xff0088e2), Color(0xff0075cd), Color(0xff0063b8)],
          appTitle: "Güvenlik Kamerası",
          appIcon: "images/dashcam_white.png",
        ));
  }
}
