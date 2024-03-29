import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sars/Control/Services/auth.dart';
import 'package:sars/Control/Controller/controller.dart';
import 'package:sars/Model/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user;
    return StreamProvider<User?>.value(
      value: AuthUserMethod().getUserAuth,
      initialData: user,
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Controller(),
      ),
    );
  }
}
  /*options: const FirebaseOptions(
      apiKey: "XXX",
      appId: "XXX",
      messagingSenderId: "XXX",
      projectId: "XXX",
    ),*/
