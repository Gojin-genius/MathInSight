//server/main.dart

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';
import 'lib/db_service.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
    initDatabase();

    final dbMiddleware = provider<Database>((_) => db);

    final finalHandler = handler.use(dbMiddleware);

    return serve(finalHandler, ip, port)
      ..then((_) => print('server started...'));
      
}