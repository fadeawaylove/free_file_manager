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
      ),
      initialRoute: "/home",
      routes: PageRouter.routes,
      onGenerateRoute: PageRouter.generateRoute,
      onUnknownRoute: PageRouter.unknowPageRoute,
    );
  }
}
