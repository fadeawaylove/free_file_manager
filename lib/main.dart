import 'package:flutter/material.dart';
import 'routes/route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free FileManager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //   bottomSheetTheme:
        //       BottomSheetThemeData(backgroundColor: Colors.transparent),
      ),
      routes: PageRouter.routes,
      initialRoute: PageRouter.initialRoute,
      onGenerateRoute: PageRouter.generateRoute,
      onUnknownRoute: PageRouter.unknowPageRoute,
    );
  }
}
