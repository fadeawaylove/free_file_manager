import 'package:flutter/material.dart';
import 'package:free_file_manager/apis/gitee_api.dart';
import 'package:free_file_manager/models/user_model.dart';
import 'package:free_file_manager/utils/sp_util.dart';

import '/constants.dart';
import 'file_explorer.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  final String title = "Free FileManager";
  static const String routeName = "/home";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserModel? userModel;
  GlobalKey menuKey = GlobalKey();

  Future<UserModel?> getUserInfo() async {
    return await GiteeApi.getUserInfo();
  }

  Future logOut({bool showBar = true}) async {
    SpUtil.remove("user_info").then((_) {
      SpUtil.remove("token").then((_) {
        if (showBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('退出登录'),
              duration: Duration(milliseconds: 2000),
            ),
          );
        }
        Navigator.pushNamed(context, "/login");
      });
    });
  }

  showMenus(BuildContext context) async {
    final render = menuKey.currentContext!.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          render.localToGlobal(Offset.zero).dx,
          render.localToGlobal(Offset.zero).dy + 60,
          double.infinity,
          double.infinity),
      items: [
        PopupMenuItem(
            textStyle: const TextStyle(fontSize: 16, color: Colors.black),
            child: const Text("注销"),
            onTap: () {
              logOut();
            }),
      ],
    );
  }

  TextEditingController searchTextController = TextEditingController();

  final ValueNotifier<Future> listFutureNotifier =
      ValueNotifier<Future>(GiteeApi.getAllRepos());

  void setListFutureNotifier(Future future) {
    listFutureNotifier.value = future;
  }

  void showDeleteDialog(String repoName, String owner, String repo) {
    // 删除仓库对话
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: const Text("删除仓库?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text('【$repoName】'), const Text("一旦删除，无法恢复！")],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("取消")),
              TextButton(
                child: const Text('确认'),
                onPressed: () {
                  debugPrint("$owner $repo");
                  GiteeApi.removeRepo(owner, repo).then((value) {
                    debugPrint(value.toString());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('删除仓库【$repoName】成功!'),
                        duration: const Duration(milliseconds: 1200),
                      ),
                    );
                    Navigator.pop(context);
                    setListFutureNotifier(GiteeApi.getAllRepos());
                  });
                },
              ),
            ],
          );
        });
  }

  Widget _buildListFuture(BuildContext context, Future value, Widget? child) {
    return FutureBuilder(
      future: value,
      builder: (context, snapshot) {
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
        List repos = snapshot.data as List<dynamic>;

        return ListView.separated(
          separatorBuilder: (context, index) {
            return const Divider(
              thickness: 1,
            );
          },
          primary: true,
          shrinkWrap: true,
          itemCount: repos.length,
          itemBuilder: (BuildContext context, int index) {
            Map currentRepo = repos[index];
            String currentRepoPath = currentRepo["path"];
            String currentRepoName = currentRepo["name"];
            String currentRepoHumanNmae = currentRepo["human_name"];
            String currentRepoOwner = currentRepo["owner"]["login"];
            String repoType = "private";
            String leadingText = "私";
            if (currentRepo["public"] && !currentRepo["private"]) {
              repoType = "public";
              leadingText = "公";
            }
            return ListTile(
              trailing: TextButton(
                onPressed: () => {
                  showDeleteDialog(
                      currentRepoHumanNmae, currentRepoOwner, currentRepoPath)
                },
                child: const Text("删除"),
              ),
              leading: Container(
                padding: const EdgeInsets.only(left: 2, right: 2),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.lightBlueAccent),
                ),
                child: RichText(
                  text: TextSpan(
                    text: leadingText,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.blueAccent),
                  ),
                ),
              ),
              minLeadingWidth: 6,
              onTap: () {
                // 到仓库页面
                FileExplorEntranceArgument pageArgument =
                    FileExplorEntranceArgument.fromRepoList(
                        currentRepoOwner, currentRepoPath, repoType,
                        filePath: "/", sha: "master", name: currentRepoName);
                debugPrint(pageArgument.toString());
                Navigator.pushNamed(context, FileExplorerPage.routeName,
                    arguments: pageArgument);
              },
              title: Text("${currentRepo['human_name']}"),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserInfo(),
        builder: (context, snapshot) {
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
          if (!snapshot.hasData) {
            Future.delayed(const Duration(milliseconds: 500))
                .then((value) => logOut(showBar: false));
            return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text("登陆状态失效,跳转中..."),
                ),
                body:
                    const Center(child: CircularProgressIndicator.adaptive()));
          }

          UserModel? userModel = snapshot.data as UserModel;

          return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text("FCF管理器"),
                centerTitle: true,
                actions: [
                  TextButton(
                      key: menuKey,
                      onPressed: () => showMenus(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            alignment: Alignment.centerLeft,
                            child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userModel.avatarUrl!)),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(left: 10),
                            child: Text(
                              userModel.name!,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          )
                        ],
                      ))
                ],
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Opacity(
                      opacity: 1,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              width: 220,
                              height: 40,
                              child: TextField(
                                onEditingComplete: () {
                                  setListFutureNotifier(GiteeApi.getAllRepos(
                                      q: searchTextController.text));
                                },
                                textAlignVertical: TextAlignVertical.bottom,
                                controller: searchTextController,
                                autofocus: true,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onPressed: () {
                                          if (searchTextController.text == "") {
                                            return;
                                          }
                                          searchTextController.clear();
                                          setListFutureNotifier(
                                              GiteeApi.getAllRepos());
                                        },
                                        icon: const Icon(Icons.clear)),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16))),
                                    hintText: "搜索仓库",
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    filled: true,
                                    fillColor: Colors.white),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black54),
                                  ),
                                  onPressed: () {
                                    debugPrint(searchTextController.text);
                                    setListFutureNotifier(GiteeApi.getAllRepos(
                                        q: searchTextController.text));
                                  },
                                  child: const Icon(Icons.search_rounded),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              ),
              body: ValueListenableBuilder<Future>(
                builder: _buildListFuture,
                valueListenable: listFutureNotifier,
              ));
        });
  }
}
