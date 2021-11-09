import 'dart:async';
import 'dart:io';

import 'package:briefcase/const/network.dart';
import 'package:briefcase/server/connection.dart';

/// This is the main entry point for the application. This server class handles
/// accepting connections and deferring to other parts of the software to
/// handle requests. A running instance of the application would be expected to
/// act as an API proxy for this class, as this provides essentially all of the
/// key functionality.
class BriefcaseServer {
  /// The Dart IO TCP [ServerSocket] that handles incoming requests from IPv4.
  ServerSocket? _v4Socket;

  /// The Dart IO TCP [ServerSocket] that handles incoming requests from IPv6.
  ServerSocket? _v6Socket;

  /// The unified streams for v4 and v6 sockets.
  StreamController<Socket>? _socketStreams;

  /// Returns the stream of new socket connections, if the server is running.
  /// Otherwise, returns null.
  get socketStreams => _socketStreams?.stream;

  /// Private constructor for internal use.
  BriefcaseServer._construct();

  /// Initializes and starts a [BriefcaseServer], returning the created
  /// [BriefcaseServer] instance.
  static Future<BriefcaseServer> start() async {
    final server = BriefcaseServer._construct();
    server._socketStreams = StreamController();

    // Create the server sockets and configure both to pipe any new socket
    // connections into the shared [_socketStreams].
    server._v4Socket =
        await ServerSocket.bind(InternetAddress.anyIPv4, kNetworkingPort)
          ..listen((client) => server._socketStreams!.sink.add(client));
    server._v6Socket =
        await ServerSocket.bind(InternetAddress.anyIPv6, kNetworkingPort)
          ..listen((client) => server._socketStreams!.sink.add(client));

    // Listen for new sockets, and when one connects, accept the connection
    // by passing it to the connection handler.
    server._socketStreams!.stream
        .listen((socket) => ConnectionHandler(socket: socket).accept());

    return server;
  }

  /// Closes all streams and shuts down the socket servers.
  Future<void> stop() async {
    await _socketStreams?.close();
    await _v4Socket?.close();
    await _v6Socket?.close();

    _socketStreams = null;
    _v4Socket = null;
    _v6Socket = null;
  }
}
