import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static const String _dbName = 'health_ease_db.db';
  static const int _dbVersion = 2;



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

    await db.execute('''
          CREATE TABLE appointments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          doctor_id INTEGER NOT NULL,
          patient_id INTEGER NOT NULL,
          speciality TEXT NOT NULL,
          appointment_date TEXT NOT NULL,
          appointment_time TEXT NOT NULL,
          status TEXT DEFAULT 'PENDING',
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (doctor_id) REFERENCES user(id),
          FOREIGN KEY (patient_id) REFERENCES user(id)
          )''');
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
      await db.insert('prescription', {
        'patient_id': 1,
        'doctor_id': 2,
        'prescription': 'Prescription 1',
      });
      await db.insert('medicine', {
        'name': 'Medicine 1',
        'start_date': '2025-10-22',
        'end_date': '2025-11-22',
        'dose_per_day': 2,
        'mg_per_dose': 500,
        'remaining': 2*30,
        'prescription_id': 1,
      });
      await db.insert('medicine', {
        'name': 'Medicine 2',
        'start_date': '2025-10-22',
        'end_date': '2025-11-22',
        'dose_per_day': 3,
        'mg_per_dose': 500,
        'remaining': 3*30,
        'prescription_id': 1,
      });
      final List<String> appointmentInserts = [
        '''
      INSERT INTO appointments (doctor_id, patient_id, speciality, appointment_date, appointment_time, status) 
      VALUES (2, 1, 'Cardiology', '2024-02-17', '11:00', 'PENDING')
      ''',
            '''
      INSERT INTO appointments (doctor_id, patient_id, speciality, appointment_date, appointment_time, status, notes) 
      VALUES (2, 1, 'Orthopedics', '2024-02-13', '16:45', 'CANCELLED', 'Patient rescheduled due to emergency')
      ''',
            '''
      INSERT INTO appointments (doctor_id, patient_id, speciality, appointment_date, appointment_time, status, notes) 
      VALUES (2, 1, 'Dermatology', '2024-02-18', '13:30', 'CONFIRMED', 'Follow-up for previous treatment')
      ''',
            '''     
      INSERT INTO appointments (doctor_id, patient_id, speciality, appointment_date, appointment_time, status) 
      VALUES (2, 1, 'Pediatrics', '2024-02-19', '15:20', 'PENDING')
   '''
      ];
      for (var element in appointmentInserts) {
        db.execute(element);
      }
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
