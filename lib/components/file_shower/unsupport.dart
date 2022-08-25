import 'package:flutter/material.dart';
import '../../utils/code_util.dart';
import '/components/file_shower/text_shower.dart';
import '/constants.dart';

class UnsupportFileShower extends StatelessWidget {
  final FileExplorEntranceArgument fileExplorEntranceArgument;
  const UnsupportFileShower(
      {super.key, required this.fileExplorEntranceArgument});

  @override
  Widget build(BuildContext context) {
    // 先尝试当作普通文本打开，如果不行，再显示不支持页面
    var textShower =
        TextShower(fileExplorEntranceArgument: fileExplorEntranceArgument);
    return FutureBuilder(
        future: textShower.getFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Scaffold(
                body: Center(
                    child: Container(
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator.adaptive())));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Scaffold(
                  body: Center(child: Text("Error: ${snapshot.error}")));
            }
          }
          var data = snapshot.data as List<int>;
          try {
            return textShower.getBuildWidget(utf8decode(data));
          } catch (e) {
            return Scaffold(
                appBar:
                    AppBar(title: Text(fileExplorEntranceArgument.showPath)),
                body: Center(
                    child:
                        Text("尚未适配【${fileExplorEntranceArgument.name}】类型文件")));
          }
        });
  }
}
