// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.dart';

// ignore_for_file: type=lint
class $ChatIdsTable extends ChatIds with TableInfo<$ChatIdsTable, ChatId> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatIdsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chatId,
    source,
    notificationsEnabled,
    joinedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_ids';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatId> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chat_id')) {
      context.handle(
        _chatIdMeta,
        chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chatId};
  @override
  ChatId map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatId(
      chatId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chat_id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $ChatIdsTable createAlias(String alias) {
    return $ChatIdsTable(attachedDatabase, alias);
  }
}

class ChatId extends DataClass implements Insertable<ChatId> {
  final int chatId;
  final String? source;
  final bool notificationsEnabled;
  final DateTime joinedAt;
  const ChatId({
    required this.chatId,
    this.source,
    required this.notificationsEnabled,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<int>(chatId);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  ChatIdsCompanion toCompanion(bool nullToAbsent) {
    return ChatIdsCompanion(
      chatId: Value(chatId),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      notificationsEnabled: Value(notificationsEnabled),
      joinedAt: Value(joinedAt),
    );
  }

  factory ChatId.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatId(
      chatId: serializer.fromJson<int>(json['chatId']),
      source: serializer.fromJson<String?>(json['source']),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chatId': serializer.toJson<int>(chatId),
      'source': serializer.toJson<String?>(source),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  ChatId copyWith({
    int? chatId,
    Value<String?> source = const Value.absent(),
    bool? notificationsEnabled,
    DateTime? joinedAt,
  }) => ChatId(
    chatId: chatId ?? this.chatId,
    source: source.present ? source.value : this.source,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    joinedAt: joinedAt ?? this.joinedAt,
  );
  ChatId copyWithCompanion(ChatIdsCompanion data) {
    return ChatId(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      source: data.source.present ? data.source.value : this.source,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatId(')
          ..write('chatId: $chatId, ')
          ..write('source: $source, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(chatId, source, notificationsEnabled, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatId &&
          other.chatId == this.chatId &&
          other.source == this.source &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.joinedAt == this.joinedAt);
}

class ChatIdsCompanion extends UpdateCompanion<ChatId> {
  final Value<int> chatId;
  final Value<String?> source;
  final Value<bool> notificationsEnabled;
  final Value<DateTime> joinedAt;
  const ChatIdsCompanion({
    this.chatId = const Value.absent(),
    this.source = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.joinedAt = const Value.absent(),
  });
  ChatIdsCompanion.insert({
    this.chatId = const Value.absent(),
    this.source = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.joinedAt = const Value.absent(),
  });
  static Insertable<ChatId> custom({
    Expression<int>? chatId,
    Expression<String>? source,
    Expression<bool>? notificationsEnabled,
    Expression<DateTime>? joinedAt,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (source != null) 'source': source,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (joinedAt != null) 'joined_at': joinedAt,
    });
  }

  ChatIdsCompanion copyWith({
    Value<int>? chatId,
    Value<String?>? source,
    Value<bool>? notificationsEnabled,
    Value<DateTime>? joinedAt,
  }) {
    return ChatIdsCompanion(
      chatId: chatId ?? this.chatId,
      source: source ?? this.source,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatIdsCompanion(')
          ..write('chatId: $chatId, ')
          ..write('source: $source, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatIdsTable chatIds = $ChatIdsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [chatIds];
}

typedef $$ChatIdsTableCreateCompanionBuilder =
    ChatIdsCompanion Function({
      Value<int> chatId,
      Value<String?> source,
      Value<bool> notificationsEnabled,
      Value<DateTime> joinedAt,
    });
typedef $$ChatIdsTableUpdateCompanionBuilder =
    ChatIdsCompanion Function({
      Value<int> chatId,
      Value<String?> source,
      Value<bool> notificationsEnabled,
      Value<DateTime> joinedAt,
    });

class $$ChatIdsTableFilterComposer
    extends Composer<_$AppDatabase, $ChatIdsTable> {
  $$ChatIdsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatIdsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatIdsTable> {
  $$ChatIdsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatIdsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatIdsTable> {
  $$ChatIdsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$ChatIdsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatIdsTable,
          ChatId,
          $$ChatIdsTableFilterComposer,
          $$ChatIdsTableOrderingComposer,
          $$ChatIdsTableAnnotationComposer,
          $$ChatIdsTableCreateCompanionBuilder,
          $$ChatIdsTableUpdateCompanionBuilder,
          (ChatId, BaseReferences<_$AppDatabase, $ChatIdsTable, ChatId>),
          ChatId,
          PrefetchHooks Function()
        > {
  $$ChatIdsTableTableManager(_$AppDatabase db, $ChatIdsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatIdsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatIdsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatIdsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
              }) => ChatIdsCompanion(
                chatId: chatId,
                source: source,
                notificationsEnabled: notificationsEnabled,
                joinedAt: joinedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> chatId = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
              }) => ChatIdsCompanion.insert(
                chatId: chatId,
                source: source,
                notificationsEnabled: notificationsEnabled,
                joinedAt: joinedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatIdsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatIdsTable,
      ChatId,
      $$ChatIdsTableFilterComposer,
      $$ChatIdsTableOrderingComposer,
      $$ChatIdsTableAnnotationComposer,
      $$ChatIdsTableCreateCompanionBuilder,
      $$ChatIdsTableUpdateCompanionBuilder,
      (ChatId, BaseReferences<_$AppDatabase, $ChatIdsTable, ChatId>),
      ChatId,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatIdsTableTableManager get chatIds =>
      $$ChatIdsTableTableManager(_db, _db.chatIds);
}
