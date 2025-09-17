import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';

/// A data source for managing the local SQLite database.
///
/// This class provides a singleton instance for accessing the database and includes
/// methods for creating, reading, updating, and deleting (CRUD) various types of
/// data, such as daily performance entries, CSAT scores, CQ scores, and leave entries.
class LocalDataSource {
  static Database? _database;

  // Private constructor to prevent instantiation
  LocalDataSource._();

  // Singleton instance
  static LocalDataSource? _instance;

  /// Factory constructor to return the singleton instance of [LocalDataSource].
  factory LocalDataSource() {
    _instance ??= LocalDataSource._();
    return _instance!;
  }

  /// Initializes the database.
  ///
  /// This method sets up the database connection, creates the necessary tables
  /// if they don't exist, and handles database upgrades. It should be called
  /// once at app startup.
  ///
  /// Returns a [Future] that completes with the initialized [LocalDataSource] instance.
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
            call_count INTEGER NOT NULL
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
        // Create Leave entries table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableLeaveEntries} (
            date INTEGER PRIMARY KEY,
            type INTEGER NOT NULL,
            reason TEXT
          )
        ''');
        // Create Monthly Data table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableMonthlyData} (
            month INTEGER NOT NULL,
            year INTEGER NOT NULL,
            non_billable_calls INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY (month, year)
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
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE ${AppConstants.tableLeaveEntries} (
              date INTEGER PRIMARY KEY,
              type INTEGER NOT NULL,
              reason TEXT
            )
          ''');
        }
        if (oldVersion < 6) {
          // Create the new monthly_data table
          await db.execute('''
            CREATE TABLE ${AppConstants.tableMonthlyData} (
              month INTEGER NOT NULL,
              year INTEGER NOT NULL,
              non_billable_calls INTEGER NOT NULL DEFAULT 0,
              PRIMARY KEY (month, year)
            )
          ''');

          // Re-create the daily_entries table without the non_billable_calls column
          await db.execute('''
            CREATE TABLE temp_tableEntries (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date INTEGER NOT NULL,
              login_hours INTEGER NOT NULL,
              login_minutes INTEGER NOT NULL,
              login_seconds INTEGER NOT NULL,
              call_count INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            INSERT INTO temp_tableEntries (id, date, login_hours, login_minutes, login_seconds, call_count)
            SELECT id, date, login_hours, login_minutes, login_seconds, call_count FROM ${AppConstants.tableEntries}
          ''');

          await db.execute('DROP TABLE ${AppConstants.tableEntries}');

          await db.execute('ALTER TABLE temp_tableEntries RENAME TO ${AppConstants.tableEntries}');
        }
      },
    );

    return LocalDataSource();
  }

  /// Returns the singleton instance of the [Database].
  /// If the database is not initialized, it will be initialized first.
  Future<Database> get database async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  /// Returns the path of the database file.
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, AppConstants.databaseName);
  }

  /// Closes the database connection.
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // CRUD operations for daily entries

  /// Inserts a new daily entry into the database.
  ///
  /// The [entry] is the [DailyEntry] object to be inserted.
  /// Returns the ID of the newly inserted entry.
  Future<int> insertEntry(DailyEntry entry) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts a list of daily entries in a batch transaction.
  ///
  /// The [entries] is a list of [DailyEntry] objects to be inserted.
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

  /// Retrieves all daily entries from the database, ordered by date descending.
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

  /// Retrieves all daily entries for a specific [month] and [year].
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

  /// Retrieves all daily entries within a given date range.
  ///
  /// The [startDate] and [endDate] define the range.
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

  /// Retrieves the daily entry for a specific [date].
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

  /// Updates an existing daily entry.
  ///
  /// The [entry] is the [DailyEntry] object to be updated.
  /// Returns the number of rows affected.
  Future<int> updateEntry(DailyEntry entry) async {
    final db = await database;
    return await db.update(
      AppConstants.tableEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Deletes a daily entry by its [id].
  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Monthly Data CRUD operations

  /// Saves monthly data, such as non-billable calls.
  ///
  /// The [monthlyData] is the [MonthlyData] object to be saved.
  Future<void> saveMonthlyData(MonthlyData monthlyData) async {
    final db = await database;
    await db.insert(
      AppConstants.tableMonthlyData,
      monthlyData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves monthly data for a specific [month] and [year].
  Future<MonthlyData?> getMonthlyData(int month, int year) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableMonthlyData,
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );

    if (maps.isNotEmpty) {
      return MonthlyData.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // CSAT CRUD operations

  /// Inserts a new CSAT entry into the database.
  ///
  /// The [entry] is the [CSATEntry] object to be inserted.
  /// Returns the ID of the newly inserted entry.
  Future<int> insertCSATEntry(CSATEntry entry) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableCSATEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts a list of CSAT entries in a batch transaction.
  ///
  /// The [entries] is a list of [CSATEntry] objects to be inserted.
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

  /// Retrieves all CSAT entries within a given date range.
  ///
  /// The [startDate] and [endDate] define the range.
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

  /// Retrieves all CSAT entries for a specific [month] and [year].
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

  /// Deletes a CSAT entry by its [id].
  Future<int> deleteCSATEntry(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableCSATEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all CSAT entries for a specific [date].
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

  /// Inserts a new CQ entry into the database.
  ///
  /// The [entry] is the [CQEntry] object to be inserted.
  /// Returns the ID of the newly inserted entry.
  Future<int> insertCQEntry(CQEntry entry) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableCQEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserts a list of CQ entries in a batch transaction.
  ///
  /// The [entries] is a list of [CQEntry] objects to be inserted.
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

  /// Retrieves all CQ entries from the database, ordered by audit date descending.
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

  /// Retrieves all CQ entries within a given date range.
  ///
  /// The [startDate] and [endDate] define the range.
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

  /// Retrieves all CQ entries for a specific [month] and [year].
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

  /// Retrieves the CQ entry for a specific [date].
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

  /// Updates an existing CQ entry.
  ///
  /// The [entry] is the [CQEntry] object to be updated.
  /// Returns the number of rows affected.
  Future<int> updateCQEntry(CQEntry entry) async {
    final db = await database;
    return await db.update(
      AppConstants.tableCQEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// Deletes a CQ entry by its [id].
  Future<int> deleteCQEntry(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableCQEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all CQ entries for a specific [date].
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

  /// Retrieves a list of unique month-year combinations from all entry types.
  ///
  /// This is useful for populating a list of available months for reporting.
  /// The list is sorted in descending order (most recent first).
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

  // Leave Entry CRUD operations

  /// Saves a leave entry to the database.
  ///
  /// The [entry] is the [LeaveEntry] object to be saved.
  Future<void> saveLeaveEntry(LeaveEntry entry) async {
    final db = await database;
    await db.insert(
      AppConstants.tableLeaveEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all leave entries for a specific [year] and [month].
  Future<List<LeaveEntry>> getLeaveEntriesForMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableLeaveEntries,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) {
      return LeaveEntry.fromMap(maps[i]);
    });
  }

  /// Deletes a leave entry for a specific [date].
  Future<void> deleteLeaveEntry(DateTime date) async {
    final db = await database;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    await db.delete(
      AppConstants.tableLeaveEntries,
      where: 'date = ?',
      whereArgs: [normalizedDate.millisecondsSinceEpoch],
    );
  }
}
