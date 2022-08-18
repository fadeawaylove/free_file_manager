import "dart:io";
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

final String pathSeparator = Platform.pathSeparator;

abstract class BaseModel {
  Map<String, dynamic> toJson();
}

class ConfigModel extends BaseModel {
  final String giteeToken;

  ConfigModel(this.giteeToken);

  ConfigModel.fromJson(Map<String, dynamic> json)
      : giteeToken = json['giteeToken'];

  @override
  Map<String, dynamic> toJson() => {'giteeToken': giteeToken};
}

class LocalFileUtil {
  static const String rootDirectionName = "free_file_manager";

  String dir; // a/b/c
  String name; // x.txt
  LocalFileUtil(this.dir, this.name) {
    if (dir.startsWith(pathSeparator)) {
      dir = dir.substring(1);
    }
    if (dir.endsWith(pathSeparator)) {
      dir = dir.substring(0, dir.length);
    }
  }

  Future<String> get appDocumentDirectory async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getFile() async {
    final path = await appDocumentDirectory;
    final String realPath =
        '$path$pathSeparator$rootDirectionName$pathSeparator${this.dir}';
    // 路径不存在则创建
    var dir = Directory(realPath);
    var exist = await dir.exists();
    if (!exist) {
      await dir.create(recursive: true);
    }
    return File("$realPath$pathSeparator$name");
  }

  Future<String?> readString() async {
    final file = await getFile();
    if (await file.exists()) {
      return file.readAsString();
    }
    return null;
  }

  Future<File> writeString(String content) async {
    final file = await getFile();
    return file.writeAsString(content);
  }

  Future<Uint8List?> readBytes() async {
    final file = await getFile();
    if (await file.exists()) {
      return file.readAsBytes();
    }
    return null;
  }

  Future<File> writeBytes(Uint8List byteContent) async {
    final file = await getFile();
    return file.writeAsBytes(byteContent);
  }
}

class FileMime {
  // 文件类型识别工具
  static bool isImage(String fileName) {
    final mimeType = lookupMimeType(fileName, headerBytes: []);
    debugPrint("$fileName 类型是 $mimeType");
    if (mimeType == null) {
      return false;
    }
    return mimeType.startsWith("image/");
  }

  static bool isMarkdown(String fileName) {
    return fileName.endsWith(".md");
  }

  static bool isPdf(String fileName) {
    return fileName.endsWith(".pdf");
  }
}
