import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';

class LocalDataSource {
  static Database? _database;

  // Private constructor to prevent instantiation
  LocalDataSource._();

  // Singleton instance
  static LocalDataSource? _instance;

  // Factory constructor to return the singleton instance
  factory LocalDataSource() {
    _instance ??= LocalDataSource._();
    return _instance!;
  }

  // Initialize the database
  static Future<LocalDataSource> init() async {
    if (_database != null) {
      return LocalDataSource();
    }

    // Get the database path
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    // Open the database
    _database = await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: (db, version) async {
        // Create tables
        await db.execute('''
          CREATE TABLE ${AppConstants.tableEntries} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date INTEGER NOT NULL,
            login_hours INTEGER NOT NULL,
            login_minutes INTEGER NOT NULL,
            login_seconds INTEGER NOT NULL,
            call_count INTEGER NOT NULL,
            non_billable_calls INTEGER NOT NULL DEFAULT 0
          )
        ''');
        // Create CSAT entries table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableCSATEntries} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date INTEGER NOT NULL,
            t2_count INTEGER NOT NULL,
            b2_count INTEGER NOT NULL,
            n_count INTEGER NOT NULL
          )
        ''');
        // Create CQ entries table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableCQEntries} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            audit_date INTEGER NOT NULL,
            percentage REAL NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE ${AppConstants.tableCSATEntries} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date INTEGER NOT NULL,
              t2_count INTEGER NOT NULL,
              b2_count INTEGER NOT NULL,
              n_count INTEGER NOT NULL
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE ${AppConstants.tableCQEntries} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              audit_date INTEGER NOT NULL,
              percentage REAL NOT NULL
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute('''
            ALTER TABLE ${AppConstants.tableEntries} ADD COLUMN non_billable_calls INTEGER NOT NULL DEFAULT 0
          ''');
        }
      },
    );

    return LocalDataSource();
  }

  // Get the database instance
  Future<Database> get database async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  // Get database path
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, AppConstants.databaseName);
  }

  // Close the database
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // CRUD operations for daily entries

  // Create a new entry
  Future<int> insertEntry(DailyEntry entry) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Batch insert daily entries
  Future<void> insertDailyEntries(List<DailyEntry> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var entry in entries) {
        await txn.insert(
          AppConstants.tableEntries,
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Read all entries
  Future<List<DailyEntry>> getAllEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableEntries,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return DailyEntry.fromMap(maps[i]);
    });
  }

  // Read entries for a specific month
  Future<List<DailyEntry>> getEntriesForMonth(int month, int year) async {
    final db = await database;

    // Calculate start and end dates for the month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(microseconds: 1)); // End of the last day

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableEntries,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return DailyEntry.fromMap(maps[i]);
    });
  }

  // Read entries for a specific date range
  Future<List<DailyEntry>> getEntriesForDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableEntries,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return DailyEntry.fromMap(maps[i]);
    });
  }

  // Read entry for a specific date
  Future<DailyEntry?> getEntryForDate(DateTime date) async {
    final db = await database;

    // Normalize the date to start of day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableEntries,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        normalizedDate.millisecondsSinceEpoch,
        nextDay.millisecondsSinceEpoch,
      ],
    );

    if (maps.isEmpty) {
      return null;
    }

    return DailyEntry.fromMap(maps.first);
  }

  // Read latest non-billable calls entry
  Future<DailyEntry?> getLatestNonBillableCallsEntry() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableEntries,
      where: 'non_billable_calls > ?',
      whereArgs: [0],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }
    return DailyEntry.fromMap(maps.first);
  }

  // Update an existing entry
  Future<int> updateEntry(DailyEntry entry) async {
    final db = await database;
    return await db.update(
      AppConstants.tableEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Delete an entry
  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CSAT CRUD operations

  // Create a new CSAT entry
  Future<int> insertCSATEntry(CSATEntry entry) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableCSATEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Batch insert CSAT entries
  Future<void> insertCSATEntries(List<CSATEntry> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var entry in entries) {
        await txn.insert(
          AppConstants.tableCSATEntries,
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Read CSAT entries for a specific date range
  Future<List<CSATEntry>> getCSATEntriesForDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCSATEntries,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return CSATEntry.fromMap(maps[i]);
    });
  }

  // Read CSAT entries for a specific month
  Future<List<CSATEntry>> getCSATEntriesForMonth(int month, int year) async {
    final db = await database;

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(microseconds: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCSATEntries,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) {
      return CSATEntry.fromMap(maps[i]);
    });
  }

  // Delete a CSAT entry
  Future<int> deleteCSATEntry(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableCSATEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete CSAT entries for a specific date
  Future<int> deleteCSATEntriesByDate(DateTime date) async {
    final db = await database;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    return await db.delete(
      AppConstants.tableCSATEntries,
      where: 'date >= ? AND date < ?',
      whereArgs: [
        normalizedDate.millisecondsSinceEpoch,
        nextDay.millisecondsSinceEpoch,
      ],
    );
  }

  // CQ CRUD operations

  // Create a new CQ entry
  Future<int> insertCQEntry(CQEntry entry) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableCQEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Batch insert CQ entries
  Future<void> insertCQEntries(List<CQEntry> entries) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var entry in entries) {
        await txn.insert(
          AppConstants.tableCQEntries,
          entry.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Read all CQ entries
  Future<List<CQEntry>> getAllCQEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCQEntries,
      orderBy: 'audit_date DESC',
    );

    return List.generate(maps.length, (i) {
      return CQEntry.fromMap(maps[i]);
    });
  }

  // Read CQ entries for a specific date range
  Future<List<CQEntry>> getCQEntriesForDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCQEntries,
      where: 'audit_date >= ? AND audit_date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'audit_date ASC',
    );

    return List.generate(maps.length, (i) {
      return CQEntry.fromMap(maps[i]);
    });
  }

  // Read CQ entries for a specific month
  Future<List<CQEntry>> getCQEntriesForMonth(int month, int year) async {
    final db = await database;

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(microseconds: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCQEntries,
      where: 'audit_date >= ? AND audit_date <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'audit_date ASC',
    );

    return List.generate(maps.length, (i) {
      return CQEntry.fromMap(maps[i]);
    });
  }

  // Read CQ entry for a specific date
  Future<CQEntry?> getCQEntryForDate(DateTime date) async {
    final db = await database;

    // Normalize the date to start of day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCQEntries,
      where: 'audit_date >= ? AND audit_date < ?',
      whereArgs: [
        normalizedDate.millisecondsSinceEpoch,
        nextDay.millisecondsSinceEpoch,
      ],
    );

    if (maps.isEmpty) {
      return null;
    }

    return CQEntry.fromMap(maps.first);
  }

  // Update an existing CQ entry
  Future<int> updateCQEntry(CQEntry entry) async {
    final db = await database;
    return await db.update(
      AppConstants.tableCQEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Delete a CQ entry
  Future<int> deleteCQEntry(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableCQEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete CQ entries for a specific date
  Future<int> deleteCQEntriesByDate(DateTime date) async {
    final db = await database;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final nextDay = normalizedDate.add(const Duration(days: 1));

    return await db.delete(
      AppConstants.tableCQEntries,
      where: 'audit_date >= ? AND audit_date < ?',
      whereArgs: [
        normalizedDate.millisecondsSinceEpoch,
        nextDay.millisecondsSinceEpoch,
      ],
    );
  }

  // Get all unique month-year combinations from daily, CSAT, and CQ entries
  Future<List<Map<String, int>>> getUniqueMonthYearCombinations() async {
    final db = await database;
    final Set<String> uniqueCombinations = {};
    final List<Map<String, int>> result = [];

    // Fetch dates from daily entries
    final List<Map<String, dynamic>> dailyMaps = await db.query(
      AppConstants.tableEntries,
      columns: ["date"],
      distinct: true,
    );
    for (var map in dailyMaps) {
      final date = DateTime.fromMillisecondsSinceEpoch(map["date"] as int);
      uniqueCombinations.add("${date.month}-${date.year}");
    }

    // Fetch dates from CSAT entries
    final List<Map<String, dynamic>> csatMaps = await db.query(
      AppConstants.tableCSATEntries,
      columns: ["date"],
      distinct: true,
    );
    for (var map in csatMaps) {
      final date = DateTime.fromMillisecondsSinceEpoch(map["date"] as int);
      uniqueCombinations.add("${date.month}-${date.year}");
    }

    // Fetch dates from CQ entries
    final List<Map<String, dynamic>> cqMaps = await db.query(
      AppConstants.tableCQEntries,
      columns: ["audit_date"],
      distinct: true,
    );
    for (var map in cqMaps) {
      final date = DateTime.fromMillisecondsSinceEpoch(map["audit_date"] as int);
      uniqueCombinations.add("${date.month}-${date.year}");
    }

    // Convert unique combinations to desired format and sort
    final List<DateTime> sortedDates = uniqueCombinations.map((e) {
      final parts = e.split('-');
      return DateTime(int.parse(parts[1]), int.parse(parts[0]));
    }).toList();

    sortedDates.sort((a, b) => b.compareTo(a)); // Sort in descending order (latest first)

    for (var date in sortedDates) {
      result.add({"month": date.month, "year": date.year});
    }

    return result;
  }
}