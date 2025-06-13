// lib/data/diagnosis_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diagnosis_model.dart';

class DiagnosisDatabase {
  static final DiagnosisDatabase instance = DiagnosisDatabase._init();
  static Database? _database;

  DiagnosisDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diagnosis.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE diagnoses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      label TEXT,
      confidence REAL,
      timestamp TEXT,
      imageBase64 TEXT
    )
    ''');
  }

  Future<void> insertDiagnosis(Diagnosis diagnosis) async {
    final db = await instance.database;
    await db.insert('diagnoses', diagnosis.toMap());
  }

  Future<List<Diagnosis>> getAllDiagnoses() async {
    final db = await instance.database;
    final result = await db.query('diagnoses', orderBy: 'timestamp DESC');
    return result.map((map) => Diagnosis.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
