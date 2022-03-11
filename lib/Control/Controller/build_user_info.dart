import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sars/Control/Controller/push_user_info.dart';
import 'package:sars/Control/Services/database_services.dart';
import 'package:sars/Model/user.dart';

class BuildUserInfoStream extends StatefulWidget {
  final User userId;
  const BuildUserInfoStream({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<BuildUserInfoStream> createState() => _BuildUserInfoStreamState();
}

class _BuildUserInfoStreamState extends State<BuildUserInfoStream> {
  @override
  Widget build(BuildContext context) {
    final user = widget.userId;
    List<User> announcementData = [];

    return StreamProvider<List<User>>.value(
        initialData: announcementData,
        value: DatabaseFeatures().getUserInfo,
        child: PushUserInfo(
          userId: user,
        ));
  }
}