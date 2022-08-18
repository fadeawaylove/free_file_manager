/*
展示markdown文件内容
*/
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_markdown/flutter_markdown.dart';
import '/apis/gitee_api.dart';
import 'base_shower.dart';

class MarkDownShower extends BaseShower {
  const MarkDownShower({Key? key, required super.fileExplorEntranceArgument})
      : super(key: key);

  @override
  Widget getBuildWidget(futureData) {
    return Scaffold(
        appBar: AppBar(title: Text(fileExplorEntranceArgument.showPath)),
        body: Markdown(
      data: futureData,
      selectable: true,
      softLineBreak: true,
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
      ),
    ));
  }

  @override
  Future getFuture() {
    return GiteeApi.getFileBlobsString(fileExplorEntranceArgument.owner,
        fileExplorEntranceArgument.repo, fileExplorEntranceArgument.sha);
  }
}
