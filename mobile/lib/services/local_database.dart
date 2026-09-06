import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dhatu_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const textNullable = 'TEXT';
    
    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  collectorId $textNullable,
  materialCategory $textType,
  weightKg $realType,
  syncStatus $textType,
  paymentMethod $textNullable,
  createdAt $textType
)
''');

    await db.execute('''
CREATE TABLE ai_feedback (
  id $idType,
  imagePath $textType,
  predictedCategory $textType,
  actualCategory $textType,
  syncStatus $textType,
  createdAt $textType
)
''');
  }

  Future<void> insertTransaction(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('transactions', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    final db = await instance.database;
    return await db.query('transactions', where: 'syncStatus = ?', whereArgs: ['Saved Offline']);
  }

  Future<void> updateTransactionSyncStatus(String id, String status) async {
    final db = await instance.database;
    await db.update('transactions', {'syncStatus': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
