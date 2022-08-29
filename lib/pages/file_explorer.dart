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

  setDividerSelected() {
    verticalDividerColor = Colors.black;
  }

  setDividerUnSelected() {
    verticalDividerColor = Colors.black26;
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
    fileItemList = pathMap[0]!;
  }

  filterRepoTreeData(String searchValue) {
    matchName() {}
  }

  TextEditingController searchTextController = TextEditingController();

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
                      height: 30,
                      child: TextField(
                        cursorHeight: 20,
                        // onEditingComplete: () {
                        //   setListFutureNotifier(GiteeApi.getAllRepos(
                        //       q: searchTextController.text));
                        // },
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
                                  // setListFutureNotifier(
                                  //     GiteeApi.getAllRepos());
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
                          itemCount: fileItemList.length,
                          itemBuilder: (context, index) {
                            return FileOneItemWidget(
                                fileTreeItem: fileItemList[index]);
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
                      width: 2,
                      child: TextButton(
                          style: ButtonStyle(
                            maximumSize: MaterialStateProperty.all(
                                const Size.fromWidth(2)),
                            minimumSize: MaterialStateProperty.all(
                                const Size.fromWidth(2)),
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
                          child: Container()

                          // VerticalDivider(
                          //   width: 0,
                          //   thickness: 1,
                          //   color: verticalDividerColor,
                          // )

                          ))),
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
          visualDensity: VisualDensity(vertical: -4),
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
                visualDensity: VisualDensity(vertical: -4),
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

class ResizebleWidget extends StatefulWidget {
  final Widget child;
  ResizebleWidget({required this.child});

  @override
  _ResizebleWidgetState createState() => _ResizebleWidgetState();
}

const ballDiameter = 30.0;

class _ResizebleWidgetState extends State<ResizebleWidget> {
  double height = 400;
  double width = 200;

  double top = 0;
  double left = 0;

  void onDrag(double dx, double dy) {
    var newHeight = height + dy;
    var newWidth = width + dx;

    setState(() {
      height = newHeight > 0 ? newHeight : 0;
      width = newWidth > 0 ? newWidth : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: top,
          left: left,
          child: Container(
            height: height,
            width: width,
            color: Colors.red[100],
            child: widget.child,
          ),
        ),
        // top left
        Positioned(
          top: top - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;
              var newHeight = height - 2 * mid;
              var newWidth = width - 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top + mid;
                left = left + mid;
              });
            },
          ),
        ),
        // top middle
        Positioned(
          top: top - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newHeight = height - dy;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                top = top + dy;
              });
            },
          ),
        ),
        // top right
        Positioned(
          top: top - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + (dy * -1)) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),
        // center right
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newWidth = width + dx;

              setState(() {
                width = newWidth > 0 ? newWidth : 0;
              });
            },
          ),
        ),
        // bottom right
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left + width - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = (dx + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),
        // bottom center
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newHeight = height + dy;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
              });
            },
          ),
        ),
        // bottom left
        Positioned(
          top: top + height - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var mid = ((dx * -1) + dy) / 2;

              var newHeight = height + 2 * mid;
              var newWidth = width + 2 * mid;

              setState(() {
                height = newHeight > 0 ? newHeight : 0;
                width = newWidth > 0 ? newWidth : 0;
                top = top - mid;
                left = left - mid;
              });
            },
          ),
        ),
        //left center
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              var newWidth = width - dx;

              setState(() {
                width = newWidth > 0 ? newWidth : 0;
                left = left + dx;
              });
            },
          ),
        ),
        // center center
        Positioned(
          top: top + height / 2 - ballDiameter / 2,
          left: left + width / 2 - ballDiameter / 2,
          child: ManipulatingBall(
            onDrag: (dx, dy) {
              setState(() {
                top = top + dy;
                left = left + dx;
              });
            },
          ),
        ),
      ],
    );
  }
}

class ManipulatingBall extends StatefulWidget {
  ManipulatingBall({Key? key, required this.onDrag});

  final Function onDrag;

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
  double initX = 200;
  double initY = 0;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
    });
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
        width: ballDiameter,
        height: ballDiameter,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
