import 'dart:ui';
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
  List<FileTreeItemModel> fileItemList = <FileTreeItemModel>[];
  double treeWidth = 240;
  Color verticalDividerColor = Colors.black26;
  double dividerWidth = 2;
  List<FileTreeItemModel> searchResult = <FileTreeItemModel>[];
  late List originTreeData;

  TextEditingController searchTextController = TextEditingController();

  setDividerSelected() {
    verticalDividerColor = Colors.black54;
    dividerWidth = 4;
  }

  setDividerUnSelected() {
    verticalDividerColor = Colors.black26;
    dividerWidth = 2;
  }

  Widget fileTreeWidget = Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Container(
              alignment: Alignment.center,
              child: const CircularProgressIndicator.adaptive())));

  Future prepareRepoTreeData() async {
    FileExplorEntranceArgument fileInfo = widget.fileExplorEntranceArgument;
    Map res = await GiteeApi.getRepoTree(
        fileInfo.owner, fileInfo.repo, fileInfo.sha,
        recursive: 1);
    originTreeData = res["tree"];
    Map<int, List<FileTreeItemModel>> pathMap = {};

    int maxDepth = 0;
    for (Map<String, dynamic> n in originTreeData) {
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
    fileItemList = pathMap[0]!;
  }

  filterRepoTreeData(String searchValue) {
    searchResult = <FileTreeItemModel>[];
    matchName(FileTreeItemModel node) {
      if (node.name.contains(searchValue)) {
        searchResult.add(node);
      }
      if (node.children.isNotEmpty) {
        for (var n in node.children) {
          matchName(n);
        }
      }
    }

    for (var node in fileItemList) {
      matchName(node);
    }
    debugPrint(searchResult.toString());
  }

  Future buildFileTreeWidget() async {
    setState(() {
      fileTreeWidget = Scaffold(
          appBar: AppBar(),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  width: treeWidth,
                  child: Column(children: [
                    Container(
                      alignment: Alignment.topLeft,
                      height: 30,
                      child: TextField(
                        cursorHeight: 20,
                        onEditingComplete: () {
                          filterRepoTreeData(searchTextController.text);
                          buildFileTreeWidget();
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            filterRepoTreeData(value);
                          }
                          buildFileTreeWidget();
                        },
                        textAlignVertical: TextAlignVertical.bottom,
                        controller: searchTextController,
                        autofocus: true,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onPressed: () {
                                  if (searchTextController.text == "") {
                                    return;
                                  }
                                  searchTextController.clear();
                                  buildFileTreeWidget();
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  size: 16,
                                )),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black12,
                                    width: 20,
                                    style: BorderStyle.solid),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(0))),
                            hintText: "搜索",
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return const Divider(
                              thickness: 1,
                              height: 0,
                              color: Colors.black12,
                            );
                          },
                          itemCount: searchTextController.text.isEmpty
                              ? fileItemList.length
                              : searchResult.length,
                          itemBuilder: (context, index) {
                            return FileOneItemWidget(
                                fileTreeItem: searchTextController.text.isEmpty
                                    ? fileItemList[index]
                                    : searchResult[index]);
                          },
                        ))
                  ])),
              GestureDetector(
                  onPanStart: (DragStartDetails details) {
                    setDividerSelected();
                    buildFileTreeWidget();
                  },
                  onPanEnd: (details) {
                    setDividerUnSelected();
                    buildFileTreeWidget();
                  },
                  onPanUpdate: (DragUpdateDetails details) {
                    double nextWidth = treeWidth + details.delta.dx;
                    setDividerSelected();
                    if (nextWidth < 50) {
                      return;
                    }
                    treeWidth = treeWidth + details.delta.dx;
                    buildFileTreeWidget();
                  },
                  child: Container(
                      color: verticalDividerColor,
                      alignment: Alignment.center,
                      width: dividerWidth,
                      child: TextButton(
                          style: ButtonStyle(
                            maximumSize: MaterialStateProperty.all(
                                Size.fromWidth(dividerWidth)),
                            minimumSize: MaterialStateProperty.all(
                                Size.fromWidth(dividerWidth)),
                            mouseCursor: MaterialStateProperty.all(
                                SystemMouseCursors.resizeLeftRight),
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
                          onHover: (val) {
                            if (val) {
                              setDividerSelected();
                            } else {
                              setDividerUnSelected();
                            }
                            buildFileTreeWidget();
                          },
                          onPressed: () {},
                          child: Container()))),
              const Expanded(
                flex: 1,
                child: Text("右边内容"),
              )
            ],
          ));
    });
  }

  @override
  void initState() {
    super.initState();
    prepareRepoTreeData().then((value) => buildFileTreeWidget());
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

  setChildren() {
    children = <Widget>[];
    FileTreeItemModel fileTreeItem = widget.fileTreeItem;
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
  }

  showChildren() {
    setState(() {
      setChildren();
      childrenShowed = !childrenShowed;
      selected = !selected;
    });
  }

  @override
  void initState() {
    super.initState();
    setChildren();
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
          visualDensity: const VisualDensity(vertical: -4),
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
                visualDensity: const VisualDensity(vertical: -4),
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
