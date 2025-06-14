// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

HttpServer? _server; // Holds the running server instance

typedef BlinkCallback = void Function(bool isIntentional);

Future<void> startBlinkServer(BlinkCallback onBlinkReceived) async {
  if (_server != null) {
    // Server already running
    return;
  }

  handler(Request request) async {
    if (request.method == 'POST' && request.url.path == 'blink') {
      try {
        final body = await request.readAsString();
        final data = jsonDecode(body);
        if (data["blink"] == "intentional") {
          onBlinkReceived(true); // notify the app
          return Response.ok('Blink Received');
        }
      } catch (e) {
        print("Error: $e");
        onBlinkReceived(false);
        return Response.internalServerError(body: 'Error');
      }
    }
    return Response.notFound('Not Found');
  }

  _server = await io.serve(handler, '0.0.0.0', 5000);
  print('📡 Server listening on http://${_server!.address.host}:${_server!.port}');
}

Future<void> stopBlinkServer() async {
  if (_server != null) {
    await _server!.close();
    print('🛑 Server on port 5000 stopped');
    _server = null;
  }
}
