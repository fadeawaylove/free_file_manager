// future_builder分封装的组件

import 'package:flutter/material.dart';

class CommonFutureBuilder extends StatelessWidget {
  final Future? future;
  final Function buidWidgetFunction;
  const CommonFutureBuilder({super.key, this.future, required this.buidWidgetFunction});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
              child: Container(
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator.adaptive()));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
        }
        return buidWidgetFunction(snapshot.data);
      },
    );
  }
}
