import 'package:flutter/material.dart';
import '/components/file_shower/distribute_shower.dart';
import '/constants.dart';

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({super.key, required this.fileExplorEntranceArgument});
  static String routeName = "/file/detail";

  final FileExplorEntranceArgument fileExplorEntranceArgument;

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  @override
  Widget build(BuildContext context) {
    var repoInfo = widget.fileExplorEntranceArgument;
    String pageType = repoInfo.type;

    // 点击文件
    if (pageType == "blob") {
      // 文件大小
      int fileSize = repoInfo.size;
      if (fileSize > 1024 * 1024 * 100) {
        // 文件大于1M，手动点击下载
        return Scaffold(
          appBar: AppBar(
            title: Text(repoInfo.filePath),
          ),
          body: Center(
            child: TextButton(
              onPressed: () {
                debugPrint(fileSize.toString());
              },
              child: const Icon(Icons.file_download),
            ),
          ),
        );
      }
    }
    return getShowerFileWidget(repoInfo);
  }
}
