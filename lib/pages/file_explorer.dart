import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';
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
    String showPath = repoInfo.showPath;

    // 点击文件
    if (pageType == "blob") {
      // 文件大小
      int fileSize = repoInfo.size;
      if (fileSize > 1024 * 1024 * 100) {
        // 文件大于1M，手动点击下载
        return Scaffold(
          appBar: AppBar(
            title: Text(showPath),
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

      return getShowerFileWidget(repoInfo);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(showPath),
      ),
      body: FutureBuilder(
          future:
              GiteeApi.getRepoTree(repoInfo.owner, repoInfo.repo, repoInfo.sha),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                  child: Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator.adaptive()));
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
            }
            // debugPrint(snapshot.data.toString());
            List treeData = snapshot.data["tree"];
            return ListView.separated(
                itemBuilder: (context, index) {
                  Map item = treeData[index];
                  String type = item["type"];
                  var itemIcon = const Icon(Icons.file_open_outlined);
                  if (type == "tree") {
                    itemIcon = const Icon(Icons.folder_outlined);
                  }
                  // type tree-文件夹  blob-文件
                  // 如果是文件夹，用文件夹的icon，如果是文件，用文件的icon
                  // debugPrint(item.toString());
                  return ListTile(
                      leading: itemIcon,
                      onTap: () => Navigator.pushNamed(
                            context,
                            FileExplorerPage.routeName,
                            arguments: FileExplorEntranceArgument(
                                owner: repoInfo.owner,
                                repo: repoInfo.repo,
                                sha: item["sha"],
                                name: item["path"],
                                type: type,
                                size: item["size"],
                                showPath: "$showPath/${item['path']}",
                                repoType: repoInfo.repoType),
                          ),
                      title: Text(
                        item['path'],
                      ));
                },
                separatorBuilder: (context, index) {
                  return const Divider(thickness: 1);
                },
                itemCount: treeData.length);
          }),
    );
  }
}
