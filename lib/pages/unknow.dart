import 'package:flutter/material.dart';
import '/constants.dart';

class UnknowPage extends StatelessWidget {
  const UnknowPage({Key? key}) : super(key: key);
  static const String routeName = "/unknow";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("404"),
        toolbarHeight: defaultAppBarHeight,
      ),
      body: Center(
          child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xff5d5e62),
        child: const Image(image: AssetImage('images/404.png')),
      )),
    );
  }
}
