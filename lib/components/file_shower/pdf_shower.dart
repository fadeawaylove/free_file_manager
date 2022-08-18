/*
展示图片文件
*/
import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';
import 'base_shower.dart';
import 'package:pdfx/pdfx.dart';

class PdfShower extends BaseShower {
  const PdfShower({Key? key, required super.fileExplorEntranceArgument})
      : super(key: key);

  @override
  Widget getBuildWidget(dynamic futureData) {
    final pdfController =
        PdfController(document: PdfDocument.openFile(futureData.path));

    return Scaffold(
        appBar: AppBar(title: Text(fileExplorEntranceArgument.showPath)),
        body: PdfView(
      scrollDirection: Axis.vertical,
      controller: pdfController,
      pageSnapping: false,
      renderer: (PdfPage page) => page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.jpeg,
        backgroundColor: '#FFFFFF',
      ),
    ));
  }

  @override
  Future getFuture() {
    return GiteeApi.getFileBlobsFile(fileExplorEntranceArgument.owner,
        fileExplorEntranceArgument.repo, fileExplorEntranceArgument.sha);
  }
}
