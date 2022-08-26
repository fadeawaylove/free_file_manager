const double defaultAppBarHeight = 60;

const String giteeTokenKey = "giteeToken";

class FileExplorEntranceArgument {
  // 文件浏览页面的传参
  static String? _owner; // 仓库所有者
  static String? _repo; // 仓库路径(path)，不变的
  static String? _repoType; // 共有-public  私有-private

  String sha; // 文件（夹）sha值
  String name; // 当前文件（夹）名称
  String type; // blob文件，tree目录
  String filePath; // 文件路径 img/20210325225741.png
  int size; // 文件大小(目录则为0)
  int recursive; // 递归展示所有目录 0-不递归 1-递归

  String get owner {
    return _owner!;
  }

  String get repo {
    return _repo!;
  }

  String get repoType {
    return _repoType!;
  }

  static setCommomInfo(String o, String r, String rt) {
    // 设置仓库公共信息
    _owner = o;
    _repo = r;
    _repoType = rt;
  }

  FileExplorEntranceArgument.fromRepoList(
    String owner,
    String repo,
    String repoType, {
    required this.sha,
    required this.name,
    required this.filePath,
    this.recursive = 0,
    this.type = "tree",
    this.size = 0,
  }) {
    setCommomInfo(owner, repo, repoType);
  }

  FileExplorEntranceArgument({
    required this.sha,
    required this.name,
    required this.filePath,
    this.recursive = 0,
    this.type = "tree",
    this.size = 0,
  });

  @override
  String toString() {
    return """
    {owner: $owner, repo: $repo, repoType: $repoType, filePath: $filePath, 
    sha: $sha, name: $name, type: $type, size: $size, recursive: $recursive}""";
  }
}
