/*
展示图片文件
*/
import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';
import 'base_shower.dart';

class ImageShower extends BaseShower {
  const ImageShower({Key? key, required super.fileExplorEntranceArgument})
      : super(key: key);

  @override
  Widget getBuildWidget(dynamic futureData) {
    return Scaffold(
        appBar: AppBar(title: Text(fileExplorEntranceArgument.showPath)),
        body: Container(
            height: double.infinity,
            alignment: Alignment.topCenter,
            child: Image.file(futureData)));
  }

  @override
  Future getFuture() {
    return GiteeApi.getFileBlobsFile(fileExplorEntranceArgument.owner,
        fileExplorEntranceArgument.repo, fileExplorEntranceArgument.sha);
  }
}
