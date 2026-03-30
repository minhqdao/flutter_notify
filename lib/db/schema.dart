import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_hrana/drift_hrana.dart';

part 'schema.g.dart';

class ChatIds extends Table {
  IntColumn get chatId => integer()();
  TextColumn get source => text().nullable()();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {chatId};
}

@DriftDatabase(tables: [ChatIds])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    final url = Platform.environment['DB_URL'];
    if (url == null) throw 'DB_URL is not set';

    final token = Platform.environment['DB_AUTH_TOKEN'];
    if (token == null) throw 'DB_AUTH_TOKEN is not set';

    return HranaDatabase(Uri.parse(url), jwtToken: token);
  }
}
