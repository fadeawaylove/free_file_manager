import 'package:flutter/material.dart';
import 'package:free_file_manager/constants.dart';
import 'package:free_file_manager/pages/setting.dart';
import '/pages/user.dart';
import '/pages/home.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  List<Widget> tabs = const [
    Tab(icon: Icon(Icons.home)),
    Tab(
        icon: Icon(
      Icons.account_circle,
    )),
    Tab(
        icon: Icon(
      Icons.settings,
    )),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(defaultAppBarHeight),
              child: TabBar(
                controller: _tabController,
                tabs: tabs,
              ),
            )),
        body: TabBarView(controller: _tabController, children: [
          const MyHomePage(),
          UserCenterPage(),
          SettingPage(tabController: _tabController)
        ]),
      ),
    );
  }
}
