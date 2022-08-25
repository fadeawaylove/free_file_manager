/*
展示器基类
*/
import 'package:flutter/material.dart';
import 'package:free_file_manager/components/common/future_builder_cpn.dart';
import '/constants.dart';

abstract class BaseShower extends StatelessWidget {
  final FileExplorEntranceArgument fileExplorEntranceArgument;
  const BaseShower({super.key, required this.fileExplorEntranceArgument});

  bool get isPrivate {
    return fileExplorEntranceArgument.repoType == "private";
  }

  bool get isPublic {
    return fileExplorEntranceArgument.repoType == "public";
  }

  // 展示的widget
  Widget getBuildWidget(dynamic futureData);

  // 获取数据的future
  Future getFuture();

  @override
  Widget build(BuildContext context) {
    return CommonFutureBuilder(
        future: getFuture(), buidWidgetFunction: getBuildWidget);
  }
}
