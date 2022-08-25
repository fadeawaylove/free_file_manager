import 'package:flutter/material.dart';
import '/components/file_shower/text_shower.dart';
import '/constants.dart';

class UnsupportFileShower extends StatelessWidget {
  final FileExplorEntranceArgument fileExplorEntranceArgument;
  const UnsupportFileShower(
      {super.key, required this.fileExplorEntranceArgument});

  @override
  Widget build(BuildContext context) {
    try {
      return TextShower(fileExplorEntranceArgument: fileExplorEntranceArgument);
    } catch (e) {
      return Scaffold(
          appBar: AppBar(title: Text(fileExplorEntranceArgument.showPath)),
          body: Center(
              child: Text("尚未适配【${fileExplorEntranceArgument.name}】类型文件")));
    }
  }
}
