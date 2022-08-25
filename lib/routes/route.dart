import 'package:flutter/material.dart';
import 'package:free_file_manager/pages/login.dart';
import 'package:free_file_manager/pages/file_explorer.dart';
import '/constants.dart';
import '/pages/file_explorer.dart';
import '/pages/unknow.dart';
import '/pages/home.dart';

class PageRouter {
  static final Map<String, WidgetBuilder> routes = {
    MyHomePage.routeName: (ctx) => const MyHomePage(),
    LoginPage.routeName: (ctx) => const LoginPage(),
  };
  static const String initialRoute = MyHomePage.routeName;
  static RouteFactory? generateRoute = (settings) {
    if (settings.name == FileExplorerPage.routeName) {
      final args = settings.arguments as FileExplorEntranceArgument;
      return MaterialPageRoute(
        builder: (context) {
          return FileExplorerPage(
            fileExplorEntranceArgument: args,
          );
        },
      );
    }
    return null;
  };

  static RouteFactory unknowPageRoute = (settings) {
    debugPrint("未知页面-->${settings.name}");
    return MaterialPageRoute(
      builder: (context) {
        return const UnknowPage();
      },
    );
  };
}
