import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:advisor_desk/core/constants/app_constants.dart';
import 'package:advisor_desk/domain/entities/daily_entry.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';
import 'package:advisor_desk/domain/entities/cq_entry.dart';
import 'package:advisor_desk/domain/entities/leave_entry.dart';
import 'package:advisor_desk/domain/entities/monthly_data.dart';
import 'package:advisor_desk/domain/entities/ai_insight.dart';

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
  static Future<LocalDataSource> init({String? userId}) async {
    // If we are switching users, we might need to close the existing DB if it's different
    // For simplicity in this singleton pattern, we might need to be careful.
    // Ideally, we should close the old one if the path is different.
    
    // However, since this is a singleton, let's assume we re-init when switching users.
    if (_database != null) {
       // If we want to force re-init with a new user, we should close it first.
       // But the current usage checks if _database != null and returns.
       // We need a way to force re-open if the user changes.
       // For now, let's assume the caller will call closeDatabase() before init() if switching users.
       // Or we can check if the current DB path matches the requested one.
    }

    // Get the database path
    final databasesPath = await getDatabasesPath();
    String dbName = AppConstants.databaseName;
    
    if (userId != null && userId != '1') {
      dbName = 'advisor_desk_$userId.db';
    }
    
    final path = join(databasesPath, dbName);

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
            custom_call_rate REAL
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
            percentage REAL NOT NULL,
            cif_id TEXT,
            caller_id TEXT,
            total_score INTEGER,
            out_of INTEGER
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
        // Create Chat History table
        await db.execute('''
          CREATE TABLE ${AppConstants.tableChatHistory} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            message TEXT NOT NULL,
            is_user INTEGER NOT NULL, -- 0 for AI, 1 for User
            timestamp INTEGER NOT NULL,
            button_text TEXT,
            navigation_route TEXT
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
        if (oldVersion < 7) {
          await db.execute('''
            ALTER TABLE ${AppConstants.tableEntries} ADD COLUMN custom_call_rate REAL
          ''');
        }
        if (oldVersion < 8) {
          // Add indexes for performance
          await db.execute('CREATE INDEX idx_entries_date ON ${AppConstants.tableEntries} (date)');
          await db.execute('CREATE INDEX idx_csat_date ON ${AppConstants.tableCSATEntries} (date)');
          await db.execute('CREATE INDEX idx_cq_date ON ${AppConstants.tableCQEntries} (audit_date)');
          await db.execute('CREATE INDEX idx_leave_date ON ${AppConstants.tableLeaveEntries} (date)');
          await db.execute('CREATE INDEX idx_monthly_data_month_year ON ${AppConstants.tableMonthlyData} (month, year)');
        }
        if (oldVersion < 9) {
           await db.execute('''
            CREATE TABLE ${AppConstants.tableChatHistory} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              message TEXT NOT NULL,
              is_user INTEGER NOT NULL, -- 0 for AI, 1 for User
              timestamp INTEGER NOT NULL,
              button_text TEXT,
              navigation_route TEXT
            )
          ''');
          await db.execute('CREATE INDEX idx_chat_timestamp ON ${AppConstants.tableChatHistory} (timestamp)');
        }
        if (oldVersion < 10) {
          await db.execute('ALTER TABLE ${AppConstants.tableCQEntries} ADD COLUMN cif_id TEXT');
          await db.execute('ALTER TABLE ${AppConstants.tableCQEntries} ADD COLUMN caller_id TEXT');
          await db.execute('ALTER TABLE ${AppConstants.tableCQEntries} ADD COLUMN total_score INTEGER');
          await db.execute('ALTER TABLE ${AppConstants.tableCQEntries} ADD COLUMN out_of INTEGER');
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

  // Monthly Data CRUD operations

  Future<void> saveMonthlyData(MonthlyData monthlyData) async {
    final db = await database;
    await db.insert(
      AppConstants.tableMonthlyData,
      monthlyData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  // Get monthly totals using SQL aggregation
  Future<Map<String, dynamic>> getMonthlyTotals(int month, int year) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1).subtract(const Duration(microseconds: 1));

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        SUM(call_count) as total_calls,
        SUM(login_hours) as total_hours,
        SUM(login_minutes) as total_minutes,
        SUM(login_seconds) as total_seconds,
        SUM(
          CASE 
            WHEN custom_call_rate IS NOT NULL THEN call_count * custom_call_rate
            ELSE call_count * ${AppConstants.baseRatePerCall}
          END
        ) as base_salary
      FROM ${AppConstants.tableEntries}
      WHERE date >= ? AND date <= ?
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {
        'count': 0,
        'total_calls': 0,
        'total_hours': 0,
        'total_minutes': 0,
        'total_seconds': 0,
        'base_salary': 0.0,
      };
    }
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

  // Leave Entry CRUD operations

  Future<void> saveLeaveEntry(LeaveEntry entry) async {
    final db = await database;
    await db.insert(
      AppConstants.tableLeaveEntries,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

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

  Future<void> deleteLeaveEntry(DateTime date) async {
    final db = await database;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    await db.delete(
      AppConstants.tableLeaveEntries,
      where: 'date = ?',
      whereArgs: [normalizedDate.millisecondsSinceEpoch],
    );
  }

  // Chat History CRUD operations
  Future<int> insertChatMessage(AiInsight message, bool isUser) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableChatHistory,
      {
        'message': message.message,
        'is_user': isUser ? 1 : 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'button_text': message.buttonText,
        'navigation_route': message.navigationRoute,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AiInsight>> getChatHistory() async {
    final db = await database;
    // Get messages from last 7 days
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableChatHistory,
      where: 'timestamp >= ?',
      whereArgs: [sevenDaysAgo],
      orderBy: 'timestamp ASC',
    );

    return List.generate(maps.length, (i) {
      return AiInsight(
        id: maps[i]['id'].toString(),
        message: maps[i]['message'],
        buttonText: maps[i]['button_text'],
        navigationRoute: maps[i]['navigation_route'],
        isUser: maps[i]['is_user'] == 1,
      );
    });
  }

  Future<void> deleteChatMessage(int id) async {
    final db = await database;
    await db.delete(
      AppConstants.tableChatHistory,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteOldChatMessages() async {
    final db = await database;
     // Delete messages older than 7 days
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    
    await db.delete(
      AppConstants.tableChatHistory,
      where: 'timestamp < ?',
      whereArgs: [sevenDaysAgo],
    );
  }

  Future<void> clearChatHistory() async {
    final db = await database;
    await db.delete(AppConstants.tableChatHistory);
  }
}
