import 'package:drift/drift.dart';
import 'package:flutter_releases/db/schema.dart';

class DatabaseService {
  DatabaseService();

  final _db = AppDatabase();

  Future<List<int>> getSubscribedUsers() async {
    final users = await (_db.select(_db.chatIds)..where((t) => t.notificationsEnabled.equals(true))).get();
    return users.map((e) => e.chatId).toList();
  }

  Future<void> registerUser(int chatId, [String? source]) => _db
      .into(_db.chatIds)
      .insertOnConflictUpdate(
        ChatIdsCompanion.insert(chatId: Value(chatId), source: Value(source), notificationsEnabled: const Value(true)),
      );

  Future<ChatId> getUserStatus(int chatId) =>
      (_db.select(_db.chatIds)..where((t) => t.chatId.equals(chatId))).getSingle();

  Future<void> unsubscribeUser(int chatId) => (_db.update(
    _db.chatIds,
  )..where((t) => t.chatId.equals(chatId))).write(const ChatIdsCompanion(notificationsEnabled: Value(false)));
}
