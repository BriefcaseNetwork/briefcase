import 'dart:io';
import 'dart:typed_data';

import 'package:briefcase/pubspec.dart';

class ConnectionHandler {
  final Socket socket;
  bool isActive;

  ConnectionHandler({
    required this.socket,
  }) : isActive = false;

  void accept() {
    isActive = true;

    socket.listen((Uint8List packet) {
      if (_rejectHTTP(packet)) return;

      String payload = String.fromCharCodes(packet);
      socket.writeln(payload);
    });
  }

  void close() {
    isActive = false;
    socket.close();
  }

  /// Checks if a given packet of bytes is an HTTP packet. If it is, it returns
  /// a message indicating that HTTP is not supported by this application and
  /// closes the connection. If the packet was an HTTP packet, this method
  /// returns true to indicate that the packet should not be processed further,
  /// otherwise it returns false.
  bool _rejectHTTP(Uint8List packet) {
    String payload = String.fromCharCodes(packet);

    if (payload.split("\n")[0].contains("HTTP/1.1")) {
      String responseText =
          "<p>Invalid protocol. This is not an HTTP service.</p>";

      socket.writeln("HTTP/1.1 400 Invalid Protocol");
      socket.writeln("X-Network-Type: briefcase");
      socket.writeln(
          "X-Network-Application: https://github.com/BriefcaseNetwork/briefcase");
      socket.writeln(
          "X-Network-Version: ${Pubspec.versionFull}+${Pubspec.versionBuild}");
      socket.writeln("Content-Type: text/html");
      socket.writeln("Content-Length: ${responseText.length}");
      socket.writeln("\n");
      socket.writeln(responseText);

      close();
      return true;
    }

    return false;
  }
}
