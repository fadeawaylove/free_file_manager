import 'dart:convert';

/**
 * 用户信息
 * {
    "id": 1975803,
    "login": "fadeaway_dai",
    "name": "邓润庭",
    "avatar_url": "https://portrait.gitee.com/uploads/avatars/user/658/1975803_fadeaway_dai_1578963506.png",
    "url": "https://gitee.com/api/v5/users/fadeaway_dai",
    "html_url": "https://gitee.com/fadeaway_dai",
    "remark": "",
    "followers_url": "https://gitee.com/api/v5/users/fadeaway_dai/followers",
    "following_url": "https://gitee.com/api/v5/users/fadeaway_dai/following_url{/other_user}",
    "gists_url": "https://gitee.com/api/v5/users/fadeaway_dai/gists{/gist_id}",
    "starred_url": "https://gitee.com/api/v5/users/fadeaway_dai/starred{/owner}{/repo}",
    "subscriptions_url": "https://gitee.com/api/v5/users/fadeaway_dai/subscriptions",
    "organizations_url": "https://gitee.com/api/v5/users/fadeaway_dai/orgs",
    "repos_url": "https://gitee.com/api/v5/users/fadeaway_dai/repos",
    "events_url": "https://gitee.com/api/v5/users/fadeaway_dai/events{/privacy}",
    "received_events_url": "https://gitee.com/api/v5/users/fadeaway_dai/received_events",
    "type": "User",
    "blog": null,
    "weibo": null,
    "bio": null,
    "public_repos": 15,
    "public_gists": 0,
    "followers": 0,
    "following": 0,
    "stared": 0,
    "watched": 25,
    "created_at": "2018-06-05T14:13:44+08:00",
    "updated_at": "2022-08-21T22:01:16+08:00",
    "email": null
}
 * 
 * 
 * 
*/

class UserModel {
  int? uid;
  String? account;
  String? name;
  String? avatarUrl;
  String? reposUrl;

  UserModel.fromJson(String userJson) {
    Map<String, dynamic> userInfo = jsonDecode(userJson);
    uid = userInfo["id"];
    account = userInfo["login"];
    name = userInfo["name"];
    avatarUrl = userInfo["avatar_url"];
    reposUrl = userInfo["repos_url"];
  }

  UserModel.fromMap(Map<String, dynamic> userInfo) {
    uid = userInfo["id"];
    account = userInfo["login"];
    name = userInfo["name"];
    avatarUrl = userInfo["avatar_url"];
    reposUrl = userInfo["repos_url"];
  }

  Map<String, dynamic> get userInfo {
    return {
      "id": uid,
      "name": name,
      "login": account,
      "avatar_url": avatarUrl,
      "repos_url": reposUrl,
    };
  }
}
