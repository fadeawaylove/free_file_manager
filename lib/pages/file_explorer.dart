import 'dart:math';

import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';
import 'package:path/path.dart' as p;
import '/components/file_shower/distribute_shower.dart';

import '/models/file_model.dart';
import '/constants.dart';

class FileExplorerPage extends StatefulWidget {
  const FileExplorerPage({super.key, required this.fileExplorEntranceArgument});
  static String routeName = "/file/detail";

  final FileExplorEntranceArgument fileExplorEntranceArgument;

  @override
  State<FileExplorerPage> createState() => _FileExplorerPageState();
}

class _FileExplorerPageState extends State<FileExplorerPage> {
  Widget fileTreeWidget = Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator.adaptive())));

  Future buildFileTreeWidget() async {
    FileExplorEntranceArgument fileInfo = widget.fileExplorEntranceArgument;
    Map res = await GiteeApi.getRepoTree(
        fileInfo.owner, fileInfo.repo, fileInfo.sha,
        recursive: 1);
    List treeData = res["tree"];
    Map<int, List<FileTreeItemModel>> pathMap = {};

    int maxDepth = 0;
    for (Map<String, dynamic> n in treeData) {
      FileTreeItemModel fileNode = FileTreeItemModel.fromMap(n);
      int depth = "/".allMatches(fileNode.path).length;
      maxDepth = max(maxDepth, depth);
      if (!pathMap.containsKey(depth)) {
        pathMap[depth] = [];
      }
      pathMap[depth]!.add(fileNode);
    }

    int currentDepth = 0;
    while (currentDepth < maxDepth) {
      for (var fNode in pathMap[currentDepth]!) {
        for (var cNode in pathMap[currentDepth + 1]!) {
          if (cNode.path.startsWith(fNode.path)) {
            fNode.addChild(cNode);
          }
        }
      }
      currentDepth += 1;
    }

    setState(() {
      fileTreeWidget = Scaffold(
          appBar: AppBar(),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  flex: 4,
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(
                        thickness: 1,
                        height: 0,
                        color: Colors.black12,
                      );
                    },
                    itemCount: pathMap[0]!.length,
                    itemBuilder: (context, index) {
                      return FileOneItemWidget(
                          fileTreeItem: pathMap[0]![index]);
                    },
                  )),
              const Expanded(
                flex: 10,
                child: Text("右边内容"),
              )
            ],
          ));
    });
  }

  @override
  void initState() {
    super.initState();
    buildFileTreeWidget();
  }

  @override
  Widget build(BuildContext context) {
    return fileTreeWidget;
  }
}

class FileOneItemWidget extends StatefulWidget {
  final FileTreeItemModel fileTreeItem;

  const FileOneItemWidget({
    Key? key,
    required this.fileTreeItem,
  }) : super(key: key);

  @override
  State<FileOneItemWidget> createState() => _FileOneItemWidgetState();
}

class _FileOneItemWidgetState extends State<FileOneItemWidget> {
  List<Widget> children = <Widget>[];
  bool childrenShowed = false;
  bool selected = false;

  List<Widget> getChildren() {
    FileTreeItemModel fileTreeItem = widget.fileTreeItem;

    List<Widget> children = [];
    for (var x in fileTreeItem.children) {
      children.add(FileOneItemWidget(fileTreeItem: x));

      if (x != fileTreeItem.children.last) {
        children.add(const Divider(
          thickness: 1,
          color: Colors.black12,
          height: 0,
          indent: 16,
        ));
      }
    }
    return children;
  }

  showChildren() {
    setState(() {
      childrenShowed = !childrenShowed;
      selected = !selected;
    });
  }

  @override
  void initState() {
    super.initState();
    children = getChildren();
  }

  @override
  Widget build(BuildContext context) {
    FileTreeItemModel fileTreeItem = widget.fileTreeItem;
    if (fileTreeItem.type == "blob") {
      return ListTile(
          onTap: () {
            // showSelected();
          },
          minVerticalPadding: 0,
          selected: selected,
          horizontalTitleGap: 4,
          dense: true,
          style: ListTileStyle.drawer,
          contentPadding: const EdgeInsets.only(left: 16),
          minLeadingWidth: 6,
          leading: const Text("  "),
          title: Text(
            fileTreeItem.name,
          ));
    }

    return Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
                onTap: () {
                  showChildren();
                },
                minVerticalPadding: 0,
                selected: selected,
                horizontalTitleGap: 4,
                contentPadding: EdgeInsets.zero,
                dense: true,
                style: ListTileStyle.drawer,
                minLeadingWidth: 6,
                leading: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(childrenShowed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right)
                    ]),
                title: Text(
                  fileTreeItem.name,
                )),
            Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: childrenShowed ? children : [],
                ))
          ],
        ));
  }
}
