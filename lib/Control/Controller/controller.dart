import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sars/Control/Services/database_services.dart';
import 'package:sars/Model/user.dart';
import 'package:sars/View/BuildWidgetsData/loading.dart';
import 'package:sars/View/MainPages/login_page.dart';
import 'package:sars/View/MainPages/main_page.dart';

class Controller extends StatelessWidget {
  const Controller({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DatabaseFeatures _databaseFeatures = DatabaseFeatures();
    final _user = Provider.of<User?>(context);
    if (_user != null) {
      return FutureBuilder<User>(
          future: _databaseFeatures.getTarget(_user.uid!),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return MainPageBuilder(currentUser: snapshot.data!);
            } else if (snapshot.hasError) {
              return const LoginBuilder();
            }
            return Scaffold(
                body: Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(180, 0, 170, 179),
                        Color.fromARGB(230, 0, 117, 122),
                      ],
                    )),
                    alignment: Alignment.center,
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Loading()
                        : const LoginBuilder()));
          }));
    }
    return const LoginBuilder();
  }
}
