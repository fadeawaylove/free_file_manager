const double defaultAppBarHeight = 60;

const String giteeTokenKey = "giteeToken";

class FileExplorEntranceArgument {
  // 文件浏览页面的传参
  final String owner; // 仓库所有者
  final String repo; // 仓库路径(path)，不变的
  final String sha; // 文件（夹）sha值
  final String name; // 当前文件（夹）名称
  final String type; // blob文件，tree目录
  String showPath; // 展示给人看的路径
  String repoType; // 共有-public  私有-private
  int size; // 文件大小(目录则为0)
  int recursive; // 递归展示所有目录 0-不递归 1-递归
  FileExplorEntranceArgument(
      {required this.owner,
      required this.repo,
      required this.sha,
      required this.name,
      this.recursive = 0,
      this.type = "tree",
      this.size = 0,
      this.showPath = "",
      this.repoType="public"});
}
