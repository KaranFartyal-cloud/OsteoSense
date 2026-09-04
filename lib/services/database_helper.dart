import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'joint_saathi.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        phone_number TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        health_center_id TEXT,
        location TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Patients table
    await db.execute('''
      CREATE TABLE patients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        contact TEXT,
        village TEXT,
        address TEXT,
        occupation TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Screenings table
    await db.execute('''
      CREATE TABLE screenings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        screening_date TEXT DEFAULT CURRENT_TIMESTAMP,
        pain_level INTEGER,
        stiffness_duration TEXT,
        swelling INTEGER,
        past_injury TEXT,
        gait_data TEXT,
        risk_level TEXT,
        confidence REAL,
        contributing_factors TEXT,
        ai_reasoning TEXT,
        doctor_recommendations TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Preventive care articles table
    await db.execute('''
      CREATE TABLE preventive_care (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        image_url TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Insert default preventive care articles
    await _insertDefaultPreventiveCare(db);
  }

  Future<void> _insertDefaultPreventiveCare(Database db) async {
    final articles = [
      {
        'category': 'exercises',
        'title': 'Knee Strengthening Exercises',
        'content': 'Simple exercises to strengthen knee muscles and reduce OA risk. Include quad sets, straight leg raises, and hamstring stretches.',
        'image_url': 'assets/images/exercise1.png'
      },
      {
        'category': 'exercises',
        'title': 'Low Impact Aerobics',
        'content': 'Walking, swimming, and cycling are excellent low-impact activities that maintain joint health without excessive stress.',
        'image_url': 'assets/images/exercise2.png'
      },
      {
        'category': 'diet',
        'title': 'Anti-Inflammatory Foods',
        'content': 'Include foods rich in omega-3 fatty acids like fish, walnuts, and flaxseeds. Add turmeric, ginger, and colorful vegetables to your diet.',
        'image_url': 'assets/images/diet1.png'
      },
      {
        'category': 'diet',
        'title': 'Calcium and Vitamin D',
        'content': 'Ensure adequate calcium and vitamin D intake through dairy products, leafy greens, and fortified foods for bone health.',
        'image_url': 'assets/images/diet2.png'
      },
      {
        'category': 'lifestyle',
        'title': 'Weight Management',
        'content': 'Maintaining a healthy weight reduces stress on weight-bearing joints and slows OA progression.',
        'image_url': 'assets/images/lifestyle1.png'
      },
      {
        'category': 'lifestyle',
        'title': 'Posture and Ergonomics',
        'content': 'Practice good posture and use ergonomic furniture to reduce joint strain during daily activities.',
        'image_url': 'assets/images/lifestyle2.png'
      }
    ];

    for (var article in articles) {
      await db.insert('preventive_care', article);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades when schema changes
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Specific operations for sync status
  Future<int> getUnsyncedCount(String table) async {
    final results = await query(
      table,
      where: 'synced = ?',
      whereArgs: [0],
    );
    return results.length;
  }

  Future<void> markAsSynced(String table, int id) async {
    await update(
      table,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sync queue operations
  Future<int> addToSyncQueue(String tableName, int recordId, String action, Map<String, dynamic> data) async {
    return await insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'data': data.toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    return await query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeFromSyncQueue(int id) async {
    await delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('users');
    await db.delete('patients');
    await db.delete('screenings');
    await db.delete('sync_queue');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
