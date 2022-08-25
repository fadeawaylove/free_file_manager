import 'dart:typed_data';
import 'dart:io' show File, Platform;
import 'package:flutter/material.dart';
import 'package:free_file_manager/models/user_model.dart';
import 'package:free_file_manager/utils/file_util.dart';
import 'package:free_file_manager/utils/sp_util.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import '/utils/code_util.dart';

class GiteeApi {
  static Map<String, String> headers = {
    "Content-Type": "application/json;charset=UTF-8"
  };
  static String host = "gitee.com";
  static String? token = "";

  static List<dynamic> processResponse(http.Response response) {
    convert.Utf8Decoder utf8decoder = const convert.Utf8Decoder();
    String responseString = utf8decoder.convert(response.bodyBytes);
    int statusCode = response.statusCode;
    var res = convert.jsonDecode(responseString);
    return [statusCode, res];
  }

  static dynamic decodeResponse(http.Response response) {
    convert.Utf8Decoder utf8decoder = const convert.Utf8Decoder();
    String responseString = utf8decoder.convert(response.bodyBytes);
    if (responseString == "") {
      return {};
    }
    return convert.jsonDecode(responseString);
  }

  static Future<bool> checkTokenValid(String? inputToken) async {
    var url = Uri.https(host, "api/v5/user", {"access_token": inputToken});

    List res = processResponse(await http.get(url, headers: headers));
    debugPrint(res.toString());
    int statusCode = res[0];
    if (statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<UserModel?> getUserInfo({String? inputToken}) async {
    String? savedToken;
    if (inputToken == null) {
      savedToken = await SpUtil.getString("token");
    } else {
      savedToken = inputToken;
    }
    if (savedToken.isEmpty) {
      return null;
    }
    // 从本地取
    String userJson = await SpUtil.getString("user_info");
    if (userJson.isNotEmpty) {
      return UserModel.fromJson(userJson);
    }
    // 从接口获取
    var url = Uri.https(host, "api/v5/user", {"access_token": savedToken});
    List res = processResponse(await http.get(url, headers: headers));
    int statusCode = res[0];
    Map<String, dynamic> userInfo = res[1];
    if (statusCode == 200) {
      // 接口获取成功则保存
      SpUtil.setString("token", savedToken);
      SpUtil.setString("user_info", convert.jsonEncode(userInfo));
      return UserModel.fromMap(userInfo);
    }
    return null;
  }

  static Future<List<dynamic>?> getRepos() async {
    String accessToken = await SpUtil.getString("token");
    String userJson = await SpUtil.getString("user_info");
    UserModel userModel = UserModel.fromJson(userJson);
    var url = Uri.https(host, "api/v5/users/${userModel.account}/repos", {
      "access_token": accessToken,
      "type": "all",
      "sort": "full_name",
      "page": "1",
      "per_page": "100"
    });
    var res = decodeResponse(await http.get(url, headers: headers));
    return res;
  }

  static Future<Map> getRepoTree(String owner, String repo, String sha,
      {int recursive = 0}) async {
    // 获取某个用户的公开仓库
    String accessToken = await SpUtil.getString("token");
    var url = Uri.https(host, "api/v5/repos/$owner/$repo/git/trees/$sha",
        {"access_token": accessToken, "recursive": "$recursive"});
    debugPrint(url.toString());
    return decodeResponse(await http.get(url, headers: headers));
  }

  static Future<List> getAllRepos(
      {String visibility = "all",
      String? affiliation,
      String? type,
      String sort = "full_name",
      String direction = "asc",
      String? q,
      String page = "1",
      String perPage = "20"}) async {
    // 列出授权用户全部仓库 https://gitee.com/api/v5/swagger#/getV5UserRepos
    String accessToken = await SpUtil.getString("token");
    Map<String, dynamic> params = {
      "access_token": accessToken,
      "visibility": visibility,
      "sort": sort,
      "page": page,
      "per_page": perPage,
      "direction": direction
    };
    if (type != null) {
      params["type"] = type;
    }
    if (affiliation != null) {
      params["affiliation"] = affiliation;
    }
    if (q != null) {
      params["q"] = q;
    }
    var url = Uri.https(host, "api/v5/user/repos", params);
    debugPrint(url.toString());
    return decodeResponse(await http.get(url, headers: headers));
  }

  static Future<Uint8List> getFileBlobs(
      String owner, String repo, String sha) async {
    // 获取网络文件具体内容
    LocalFileUtil localFileUtil = LocalFileUtil(repo, sha);
    Uint8List? fileContent = await localFileUtil.readBytes();
    if (fileContent != null) {
      debugPrint("from cache, repo is $repo, sha is $sha");
      return fileContent;
    }
    String accessToken = await SpUtil.getString("token");
    var url = Uri.https(host, "api/v5/repos/$owner/$repo/git/blobs/$sha",
        {"access_token": accessToken});
    debugPrint(url.toString());
    Map res = decodeResponse(await http.get(url, headers: headers));
    String content = res["content"];
    var ret = b64decodeRaw(content);
    await localFileUtil.writeBytes(ret);
    return ret;
  }

  static Future<String> getFileBlobsString(
      String owner, String repo, String sha) async {
    // 获取文件内容为字符串
    File cacheFile = await getFileBlobsFile(owner, repo, sha);
    return await cacheFile.readAsString();
  }

  static Future<File> getFileBlobsFile(
      String owner, String repo, String sha) async {
    // 返回文件对象
    LocalFileUtil localFileUtil = LocalFileUtil(repo, sha);
    File cacheFile = await localFileUtil.getFile();
    if (cacheFile.existsSync()) {
      debugPrint("cache file from -> ${cacheFile.toString()}");
      return cacheFile;
    }
    String accessToken = await SpUtil.getString("token");
    var url = Uri.https(host, "api/v5/repos/$owner/$repo/git/blobs/$sha",
        {"access_token": accessToken});
    debugPrint(url.toString());
    Map res = decodeResponse(await http.get(url, headers: headers));
    String content = res["content"];
    var ret = b64decodeRaw(content);
    debugPrint("cache file from -> ${cacheFile.toString()}");
    return await localFileUtil.writeBytes(ret);
  }

  static Future<dynamic> removeRepo(String owner, String repo) async {
    String accessToken = await SpUtil.getString("token");
    var url = Uri.https(
        host, "api/v5/repos/$owner/$repo", {"access_token": accessToken});
    debugPrint(url.toString());
    return decodeResponse(await http.delete(url, headers: headers));
  }
}
