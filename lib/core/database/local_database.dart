import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static const String _dbName = 'health_ease_db.db';
  static const int _dbVersion = 1;

  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _openDatabase();
    return _db!;
  }

  static Future<Database> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        user_image TEXT,
        active BOOLEAN DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        role TEXT DEFAULT 'PATIENT'
        ) ''');

    await db.execute('''
        CREATE TABLE prescription (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id INTEGER,
        doctor_id INTEGER,
        prescription TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patient_id) REFERENCES user(id),
        FOREIGN KEY (doctor_id) REFERENCES user(id)
        ) ''');

    await db.execute('''
        CREATE TABLE medicine (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          start_date DATETIME,
          end_date DATETIME,
          dose_per_day INTEGER,
          mg_per_dose INTEGER,
          remaining INTEGER,
          prescription_id INTEGER,
          is_active BOOLEAN DEFAULT 1,
          FOREIGN KEY (prescription_id) REFERENCES prescription(id)
        ) ''');

    await db.execute('''
          CREATE TABLE reminder (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicine_id INTEGER,
          time TEXT,
          is_active BOOLEAN DEFAULT 1,
          FOREIGN KEY (medicine_id) REFERENCES medicine(id)
          ) ''');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.insert('user', {
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'patient@patient.com',
        'password': 'password',
      });
      await db.insert('user', {
        'first_name': 'Jane',
        'last_name': 'Doe',
        'email': 'doctor@doctor.com',
        'password': 'password',
        'role': 'DOCTOR',
      });
    }
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  static Future<void> deleteDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    await close();
    await deleteDatabase(path);
    _db = null;
  }
}
