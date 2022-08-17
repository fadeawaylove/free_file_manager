import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/pages/unknow.dart';
import '/pages/home.dart';

class PageRouter {
  static final Map<String, WidgetBuilder> routes = {
    MyHomePage.routeName: (ctx) => const MyHomePage(),
  };
  static const String initialRoute = MyHomePage.routeName;
  static RouteFactory? generateRoute = (settings) {
    // if (settings.name == PassArgumentsScreen.routeName) {
    //   return MaterialPageRoute(
    //     builder: (context) {
    //       return const UnknowPage();
    //     },
    //   );
    // }
    // assert(false, 'Need to implement ${settings.name}');
    // final existsRoute = PageRouter.routes.containsKey(settings.name);
    // if (existsRoute) {
    //   print("我是你爸阿布");
    // }
    // print("----------------");
    // print(settings.name);
    // print("----------------");
    return null;
  };
  static RouteFactory unknowPageRoute = (settings) {
    if (kDebugMode) {
      print("未知页面-->${settings.name}");
    }
    return MaterialPageRoute(
      builder: (context) {
        return const UnknowPage();
      },
    );
  };
}
