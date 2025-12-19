import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

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

  static QueryExecutor _openConnection() => NativeDatabase.opened(sqlite3.open('sleepy-vicinity.db'));
}
