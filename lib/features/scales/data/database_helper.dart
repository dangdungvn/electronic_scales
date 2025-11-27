import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../domain/scale_station.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('scale_stations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE scale_stations ADD COLUMN image_port INTEGER DEFAULT 85',
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scale_stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ip TEXT NOT NULL,
        port INTEGER NOT NULL,
        image_port INTEGER DEFAULT 85,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> createStation(ScaleStation station) async {
    final db = await database;
    return await db.insert('scale_stations', {
      'name': station.name,
      'ip': station.ip,
      'port': station.port,
      'image_port': station.imagePort,
      'username': station.username,
      'password': station.password,
      'created_at': station.createdAt.toIso8601String(),
    });
  }

  Future<List<ScaleStation>> getAllStations() async {
    final db = await database;
    final result = await db.query('scale_stations', orderBy: 'created_at DESC');

    return result.map((json) => ScaleStation.fromJson(json)).toList();
  }

  Future<ScaleStation?> getStation(int id) async {
    final db = await database;
    final result = await db.query(
      'scale_stations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return ScaleStation.fromJson(result.first);
  }

  Future<int> updateStation(ScaleStation station) async {
    final db = await database;
    return await db.update(
      'scale_stations',
      {
        'name': station.name,
        'ip': station.ip,
        'port': station.port,
        'image_port': station.imagePort,
        'username': station.username,
        'password': station.password,
      },
      where: 'id = ?',
      whereArgs: [station.id],
    );
  }

  Future<int> deleteStation(int id) async {
    final db = await database;
    return await db.delete('scale_stations', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
