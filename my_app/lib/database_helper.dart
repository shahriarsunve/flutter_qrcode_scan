import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'app_database.db');

    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appId TEXT,
        status TEXT
      )
    ''');
  }

  Future<void> insertAppData(String appId, String status) async {
    final Database db = await instance.database;
    await db.insert('app_data', {'appId': appId, 'status': status});
  }

  Future<List<Map<String, dynamic>>> getInstallationData() async {
    final Database db = await instance.database;
    return await db.query('app_data', limit: 1);
  }

  Future<void> updateStatus(String appId, String status) async {
    final Database db = await instance.database;
    await db.update('app_data', {'status': status}, where: 'appId = ?', whereArgs: [appId]);
  }
}
