/*
展示文本文件内容
*/
import 'package:flutter/material.dart';
import '/apis/gitee_api.dart';
import 'base_shower.dart';

class TextShower extends BaseShower {
  const TextShower({Key? key, required super.fileExplorEntranceArgument})
      : super(key: key);

  @override
  Widget getBuildWidget(futureData) {
    return Scaffold(
        appBar: AppBar(title: Text(fileExplorEntranceArgument.showPath)),
        body: ListView(
          children: [
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(left: 14, top: 10),
              child: SelectableText(
                futureData,
                style: const TextStyle(fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
                toolbarOptions: const ToolbarOptions(
                  copy: true,
                  selectAll: true,
                ),
                showCursor: true,
                cursorWidth: 2,
                cursorRadius: const Radius.circular(5),
              ),
            )
          ],
        ));
  }

  @override
  Future getFuture() {
    return GiteeApi.getFileBlobsString(fileExplorEntranceArgument.owner,
        fileExplorEntranceArgument.repo, fileExplorEntranceArgument.sha);
  }
}
