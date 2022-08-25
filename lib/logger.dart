import 'dart:developer';

class Logger {
  static void debug(String message) {
    log(message, time: DateTime.now(), name: "debugger");
  }
}
