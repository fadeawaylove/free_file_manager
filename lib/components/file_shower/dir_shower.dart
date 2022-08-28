/*
展示文件夹下的内容
*/
import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';
import '/pages/file_explorer.dart';
import '/constants.dart';
import 'base_shower.dart';

class DirShower extends BaseShower {
  const DirShower({Key? key, required super.fileExplorEntranceArgument})
      : super(key: key);

  @override
  Future getFuture() {
    return GiteeApi.getRepoTree(fileExplorEntranceArgument.owner,
        fileExplorEntranceArgument.repo, fileExplorEntranceArgument.sha,
        recursive: 0);
  }

  final List<Widget> ccc = const [Text("xxx")];

  @override
  Widget getBuildWidget(dynamic futureData) {
    List treeData = futureData["tree"];
    List<Widget> children = [];

    for (var item in treeData) {
      Widget fileNode;
      String itemType = item["type"];
      String itemPath = item["path"];
      if (itemType == "blob") {
        // fileNode = Text(itemPath);
        fileNode = Text(itemPath);
      } else {
        fileNode = Column(
          children: [
            TextButton(
                onPressed: () {
                  // for(var x in [1,2,3]){
                  //   ccc.add(Text(x.toString()));
                  // }
                },
                child: Text(itemPath)),
            Column(
              children: ccc,
            )
          ],
        );
      }

      children.add(fileNode);
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(fileExplorEntranceArgument.filePath),
        ),
        body: Column(
          children: children,
        )

        // ListView.separated(
        //     itemBuilder: (context, index) {
        //       Map item = treeData[index];
        //       /* item包含的内容
        //       {
        //           "path": "20210325225741.png",  注意，这里传进来的path实际是name
        //           "mode": "100644",
        //           "type": "blob",
        //           "sha": "927e17f3ad7b8fbbbb73ad07da6f1d40035b9cf2",
        //           "size": 50365,
        //           "url": "https://gitee.com/api/v5/repos/fadeaway_dai/picgo_images/git/blobs/927e17f3ad7b8fbbbb73ad07da6f1d40035b9cf2"
        //           },
        //       */
        //       return DirSingleTree(
        //         item: item,
        //         fileInfo: fileExplorEntranceArgument,
        //       );
        //     },
        //     separatorBuilder: (context, index) {
        //       return const Divider(thickness: 1);
        //     },
        //     itemCount: treeData.length);

        );
    // return ListTile(
    //   leading: itemIcon,
    //   onTap: () {
    //     setState(() {
    //       itemIcon = Icon(Icons.arrow_downward_outlined);
    //     });
    // Navigator.pushNamed(
    //   context,
    //   FileExplorerPage.routeName,
    //   arguments: FileExplorEntranceArgument(
    //     filePath: filePath,
    //     sha: item["sha"],
    //     name: item["path"],
    //     type: type,
    //     size: item["size"],
    //   ),
    // );
    // },
    // title: Text(itemPath),
    // subtitle: Container(
    //   child: ListView.builder(
    //     shrinkWrap: true,
    //     physics: const NeverScrollableScrollPhysics(),
    //     itemCount: 4,
    //     itemBuilder: (BuildContext context, int index) {
    //       return TextButton(
    //           onPressed: () {}, child: Text(itemPath));
    //     },
    //   ),
    // )
    // );
  }
}

class DirSingleTree extends StatefulWidget {
  final Map item;
  final FileExplorEntranceArgument fileInfo;
  const DirSingleTree({required this.item, required this.fileInfo, super.key});

  @override
  State<DirSingleTree> createState() => _DirSingleTreeState();
}

class _DirSingleTreeState extends State<DirSingleTree> {
  Icon arrowIcon = const Icon(Icons.arrow_downward_sharp);
  Widget child = Text("111");

  @override
  Widget build(BuildContext context) {
    Map item = widget.item;
    var fileInfo = widget.fileInfo;

    String itemType = item["type"];
    String itemPath = item["path"];

    if (itemType == "blob") {
      return ListTile(
          title: TextButton(
              onPressed: () {}, child: ListTile(title: Text(itemPath))));
    } else {
      String fatherPath = fileInfo.filePath;
      String filePath = "$fatherPath/$itemPath";
      while (filePath.startsWith("/")) {
        filePath = filePath.substring(1);
      }

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextButton(
            onPressed: () {
              setState(() {
                child = DirShower(fileExplorEntranceArgument: fileInfo);
              });
            },
            child: Text(itemPath)),
        child
      ]);
      // ],
      // );

      // return TextButton(
      //     onPressed: () {},
      //     child: ListTile(
      //       title: Column(
      //         children: [],
      //       ),
      //     ));

      // return FutureBuilder(
      //     future:
      //         GiteeApi.getRepoTree(fileInfo.owner, fileInfo.repo, fileInfo.sha),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState != ConnectionState.done) {
      //         return Center(
      //             child: Container(
      //                 alignment: Alignment.center,
      //                 child: const CircularProgressIndicator.adaptive()));
      //       }
      //       if (snapshot.connectionState == ConnectionState.done) {
      //         if (snapshot.hasError) {
      //           return Center(child: Text("Error: ${snapshot.error}"));
      //         }
      //       }
      //       List childrenData = (snapshot.data as Map)["tree"];
      //       return Text("asdas");
      //     });
    }
  }
}
