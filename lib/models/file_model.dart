import 'package:path/path.dart' as p;

class FileTreeItemModel {
  late String name;
  late String path;
  late String mode;
  late String type;
  late String sha;
  late int size;
  late String url;
  List<FileTreeItemModel> children = <FileTreeItemModel>[];

  addChild(FileTreeItemModel cNode) {
    children.add(cNode);
  }

  FileTreeItemModel(
      {required this.path,
      required this.name,
      required this.mode,
      required this.type,
      required this.sha,
      required this.size,
      required this.url});

  FileTreeItemModel.fromMap(Map<String, dynamic> fileItem) {
    path = fileItem["path"];
    name = p.basename(path);
    mode = fileItem["mode"];
    type = fileItem["type"];
    sha = fileItem["sha"];
    size = fileItem["size"];
    url = fileItem["url"];
  }

  @override
  String toString() {
    return "{path: $path, name: $name, mode: $mode, type: $type, sha: $sha, size: $size, url: $url, children: $children}";
  }
}
