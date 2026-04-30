import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/logging/log_service.dart';
import '../services/supabase_service.dart';
import '../services/encryption_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AlmaDB {
  static Database? _db;
  static final List<Map<String, dynamic>> _webEntries = [];

  static bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static Future<void> open(String passphrase) async {
    if (kIsWeb) {
      debugPrint(
        '[AlmaDB] SQLite no se inicializa en Web. Usando almacenamiento temporal en memoria.',
      );
      return;
    }

    if (_db != null) return;

    _db = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    if (_isDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'alma_diary.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _onCreate(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE entries ADD COLUMN sentimiento TEXT',
          );
          await db.execute(
            'ALTER TABLE entries ADD COLUMN arquetipo TEXT',
          );
          await db.execute(
            'ALTER TABLE entries ADD COLUMN reflexion TEXT',
          );
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS saved_readings (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              author TEXT NOT NULL,
              quote TEXT NOT NULL,
              date_saved TEXT NOT NULL
            )
          ''');
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE entries ADD COLUMN supabase_id TEXT',
          );
          await db.execute(
            'ALTER TABLE entries ADD COLUMN synced INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  static Future<void> _onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE entries (
        id TEXT PRIMARY KEY,
        fecha TEXT NOT NULL,
        texto_encriptado TEXT NOT NULL,
        sentimiento TEXT,
        sentimiento_score REAL,
        arquetipo TEXT,
        reflexion TEXT,
        etiquetas_ia TEXT,
        supabase_id TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE saved_readings (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author TEXT NOT NULL,
        quote TEXT NOT NULL,
        date_saved TEXT NOT NULL
      )
    ''');
  }

  static Future<void> insertEntry(Map<String, dynamic> entry) async {
    if (kIsWeb) {
      _webEntries.removeWhere((item) => item['id'] == entry['id']);
      _webEntries.add(Map<String, dynamic>.from(entry));
      _webEntries.sort(
        (a, b) => (b['fecha'] ?? '').toString().compareTo((a['fecha'] ?? '').toString()),
      );
      return;
    }

    await open('');
    final db = _db!;
    entry['synced'] = 0;
    await db.insert(
      'entries',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    LogService.instance.info('Guardado local exitoso: ${entry['id']}');
  }

  static Future<List<Map<String, dynamic>>> getEntries() async {
    if (kIsWeb) {
      return _webEntries
          .map((entry) => EncryptionService.instance.decryptEntry(entry))
          .toList(growable: false);
    }

    await open('');
    final db = _db!;
    final entries = await db.query('entries', orderBy: 'fecha DESC');
    return entries;
  }

  static Future<List<Map<String, dynamic>>> searchEntries(String? query, String? arquetipo) async {
    if (kIsWeb) {
      var results = _webEntries;
      if (query != null && query.isNotEmpty) {
        results = results.where((e) =>
          (e['sentimiento'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
          (e['arquetipo'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
          (e['etiquetas_ia'] ?? '').toString().toLowerCase().contains(query.toLowerCase()) ||
          (e['fecha'] ?? '').toString().toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
      if (arquetipo != null && arquetipo.isNotEmpty) {
        results = results.where((e) => (e['arquetipo'] ?? '').toString().contains(arquetipo)).toList();
      }
      results.sort((a, b) => (b['fecha'] ?? '').toString().compareTo((a['fecha'] ?? '').toString()));
      return results.map((e) => Map<String, dynamic>.from(e)).toList(growable: false);
    }

    await open('');
    final db = _db!;
    String? whereClause;
    List<dynamic> whereArgs = [];

    List<String> conditions = [];
    if (query != null && query.isNotEmpty) {
      conditions.add('(sentimiento LIKE ? OR arquetipo LIKE ? OR etiquetas_ia LIKE ? OR fecha LIKE ?)');
      whereArgs.addAll(['%$query%', '%$query%', '%$query%', '%$query%']);
    }
    if (arquetipo != null && arquetipo.isNotEmpty) {
      conditions.add('arquetipo LIKE ?');
      whereArgs.add('%$arquetipo%');
    }

    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }

    return db.query('entries', where: whereClause, whereArgs: whereArgs, orderBy: 'fecha DESC');
  }

  static Future<void> saveReading(Map<String, dynamic> reading) async {
    if (kIsWeb) {
      debugPrint('[AlmaDB] saved_readings no soportado en web aún.');
      return;
    }
    await open('');
    final db = _db!;
    await db.insert(
      'saved_readings',
      reading,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getSavedReadings() async {
    if (kIsWeb) return [];
    await open('');
    final db = _db!;
    return db.query('saved_readings', orderBy: 'date_saved DESC');
  }

  static Future<bool> hasNetworkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any((result) => result != ConnectivityResult.none);
  }

  static Future<void> syncEntries() async {
    if (!SupabaseService.instance.isAuthenticated) {
      LogService.instance.info('Sincronización omitida: usuario no autenticado');
      return;
    }

    final hasConnection = await hasNetworkConnection();
    if (!hasConnection) {
      LogService.instance.info('Sincronización omitida: sin conexión a internet');
      return;
    }

    LogService.instance.info('Iniciando sincronización de entradas...');

    try {
      await open('');
      final db = _db!;
      final unsyncedEntries = await db.query(
        'entries',
        where: 'synced = ?',
        whereArgs: [0],
      );

      if (unsyncedEntries.isEmpty) {
        LogService.instance.info('No hay entradas pendientes de sincronización');
        return;
      }

      LogService.instance.info('${unsyncedEntries.length} entradas pendientes de sincronización');

      final supabase = SupabaseService.instance.client;

      for (final entry in unsyncedEntries) {
        try {
          final encryptedEntry = EncryptionService.instance.encryptEntry(entry);
          
          final response = await supabase.from('entries').insert({
            'id': encryptedEntry['id'],
            'user_id': SupabaseService.instance.currentUser?.id,
            'fecha': encryptedEntry['fecha'],
            'texto_encriptado': encryptedEntry['texto_encriptado'],
            'sentimiento': encryptedEntry['sentimiento'],
            'sentimiento_score': encryptedEntry['sentimiento_score'],
            'arquetipo': encryptedEntry['arquetipo'],
            'reflexion': encryptedEntry['reflexion'],
            'etiquetas_ia': encryptedEntry['etiquetas_ia'],
          }).select();

          if (response.isNotEmpty) {
            final remoteId = response.first['id'];
            await db.update(
              'entries',
              {'supabase_id': remoteId, 'synced': 1},
              where: 'id = ?',
              whereArgs: [entry['id']],
            );
            LogService.instance.info('Entrada sincronizada: ${entry['id']} -> $remoteId');
          }
        } catch (e) {
          LogService.instance.error('Error sincronizando entrada: ${entry['id']}', error: e);
        }
      }

      LogService.instance.info('Sincronización completada');
    } catch (e, st) {
      LogService.instance.error('Error en syncEntries', error: e, stackTrace: st);
    }
  }

  static Future<void> syncWithCloud() async {
    await syncEntries();
  }
}

