import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// 1. Daily Entries Table
class DailyEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();
  IntColumn get loginHours => integer()();
  IntColumn get loginMinutes => integer()();
  IntColumn get loginSeconds => integer()();
  IntColumn get callCount => integer()();
  RealColumn get customCallRate => real().nullable()();
}

// 2. CSAT Entries Table
class CsatEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get t2Count => integer()();
  IntColumn get b2Count => integer()();
  IntColumn get nCount => integer()();
}

// 3. CQ Entries Table
class CqEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get auditDate => dateTime()();
  RealColumn get percentage => real()();
  TextColumn get cifId => text().nullable()();
  TextColumn get callerId => text().nullable()();
  IntColumn get totalScore => integer().nullable()();
  IntColumn get outOf => integer().nullable()();
}

// 4. Leave Entries Table
class LeaveEntries extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get type => integer()();
  TextColumn get reason => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

// 5. Monthly Data Table
class MonthlyDataTable extends Table {
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  IntColumn get nonBillableCalls => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {month, year};
}

// 6. Chat History Table
class ChatHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get message => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get buttonText => text().nullable()();
  TextColumn get navigationRoute => text().nullable()();
}

@DriftDatabase(tables: [
  DailyEntries,
  CsatEntries,
  CqEntries,
  LeaveEntries,
  MonthlyDataTable,
  ChatHistory,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10; // Keeping sync with current version

  // Reactive Streams (Point 5: Live UI)
  Stream<List<DailyEntryData>> watchAllEntries() => select(dailyEntries).watch();
  
  Stream<List<DailyEntryData>> watchEntriesForMonth(int month, int year) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return (select(dailyEntries)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'advisor_desk_modern.db'));
    return NativeDatabase(file);
  });
}
