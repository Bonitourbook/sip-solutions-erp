import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

class ErpController {
  static final ErpController instance = ErpController._init();
  static Database? _database;

  ErpController._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('erp_juan_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            client TEXT,
            client_type TEXT,
            amount REAL,
            paid_amount REAL,
            payment_mode TEXT,
            has_delivery INTEGER,
            status TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<List<TransactionModel>> getTransactions([String? typeFilter]) async {
    final db = await instance.database;
    final result = typeFilter == null
        ? await db.query('transactions', orderBy: 'id DESC')
        : await db.query(
            'transactions',
            where: 'type = ?',
            whereArgs: [typeFilter],
            orderBy: 'id DESC',
          );

    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<double> getSum(String type) async {
    final db = await instance.database;
    final res = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );

    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<double> getPendingReceivablesTotal() async {
    final db = await instance.database;
    final res = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = 'COBRO' AND status LIKE '%Pendiente%'",
    );

    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
