import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';
import 'package:free_file_manager/components/file_shower/dir_shower.dart';
import 'package:free_file_manager/components/file_shower/image_shower.dart';
import 'package:free_file_manager/components/file_shower/md_shower.dart';
import 'package:free_file_manager/components/file_shower/pdf_shower.dart';
import 'package:mime/mime.dart';
import '/constants.dart';
import 'base_shower.dart';
import 'unsupport.dart';

class _DistributeShower extends BaseShower {
  const _DistributeShower({Key? key, required super.fileExplorEntranceArgument})
      : super(key: key);

  @override
  Widget getBuildWidget(dynamic futureData) {
    var allBytes = (futureData as List<int>);
    List<int>? headerBytes;
    if (allBytes.length < 20) {
      headerBytes = allBytes;
    } else {
      headerBytes = allBytes.sublist(0, 20);
    }
    Widget? showerWidget;
    showerWidget = getShowerFileWidget(fileExplorEntranceArgument,
        headerBytes: headerBytes);
    return showerWidget;
  }

  @override
  Future getFuture() {
    return GiteeApi.getFileBlobs(fileExplorEntranceArgument.owner,
        fileExplorEntranceArgument.repo, fileExplorEntranceArgument.sha);
  }
}

/*
指定展示文件内容的widget
*/
Widget getShowerFileWidget(FileExplorEntranceArgument fileInfo,
    {List<int>? headerBytes}) {
  debugPrint(fileInfo.toString());
  if (fileInfo.type == "tree") {
    return DirShower(fileExplorEntranceArgument: fileInfo);
  }

  // 1.人为后缀名指定
  List<String> mdFileSuffix = [".md", ".MD", ".mD", ".Md"];
  for (var element in mdFileSuffix) {
    if (fileInfo.name.endsWith(element)) {
      return MarkDownShower(fileExplorEntranceArgument: fileInfo);
    }
  }

  // 2.mime工具识别
  final String? mimeType =
      lookupMimeType(fileInfo.name, headerBytes: headerBytes);
  debugPrint("verify type -> $mimeType, from content ${headerBytes != null}");
  if (mimeType == null) {
    if (headerBytes == null) {
      return _DistributeShower(fileExplorEntranceArgument: fileInfo);
    } else {
      return UnsupportFileShower(fileExplorEntranceArgument: fileInfo);
    }
  }
  if (mimeType.contains("image")) {
    return ImageShower(fileExplorEntranceArgument: fileInfo);
  }
  if (mimeType.contains("pdf")) {
    return PdfShower(fileExplorEntranceArgument: fileInfo);
  }
  return UnsupportFileShower(fileExplorEntranceArgument: fileInfo);
}
