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
          CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            client TEXT NOT NULL,
            client_type TEXT NOT NULL,
            amount REAL NOT NULL,
            paid_amount REAL NOT NULL,
            payment_mode TEXT NOT NULL,
            has_delivery INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    if (transaction.id == null) {
      throw Exception('No se puede actualizar una transacción sin id');
    }

    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
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

  Future<double> getTotalByStatus(String status) async {
    final db = await instance.database;
    final res = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE status = ?',
      [status],
    );

    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toDouble();
    }

    return 0.0;
  }

  Future<double> getTotalPaidByType(String type) async {
    final db = await instance.database;
    final res = await db.rawQuery(
      'SELECT SUM(paid_amount) as total FROM transactions WHERE type = ?',
      [type],
    );

    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toDouble();
    }

    return 0.0;
  }

  Future<double> getPendingBalance() async {
    final db = await instance.database;
    final res = await db.rawQuery(
      'SELECT SUM(amount - paid_amount) as total FROM transactions WHERE status != ?',
      ['Pagada'],
    );

    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toDouble();
    }

    return 0.0;
  }

  Future<double> getGrossProfit() async {
    final totalSales = await getSum('VENTA');
    final totalPurchases = await getSum('COMPRA');
    return totalSales - totalPurchases;
  }

  Future<double> getProfitMargin() async {
    final totalSales = await getSum('VENTA');
    if (totalSales <= 0) return 0.0;

    final grossProfit = await getGrossProfit();
    return (grossProfit / totalSales) * 100;
  }

  Future<Map<String, dynamic>> getBusinessSummary() async {
    final totalSales = await getSum('VENTA');
    final totalPurchases = await getSum('COMPRA');
    final totalCash = await getTotalPaidByType('COBRO');
    final pending = await getPendingBalance();
    final profit = await getGrossProfit();

    return {
      'sales': totalSales,
      'purchases': totalPurchases,
      'cash': totalCash,
      'pending': pending,
      'profit': profit,
      'margin': await getProfitMargin(),
    };
  }

  Future<Map<String, dynamic>> getStockSummary() async {
    final db = await instance.database;

    final salesCount = await db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions WHERE type = ?',
      ['VENTA'],
    );

    final deliveryCount = await db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions WHERE has_delivery = 1',
      [],
    );

    final pendingCount = await db.rawQuery(
      'SELECT COUNT(*) as total FROM transactions WHERE status != ?',
      ['Pagada'],
    );

    return {
      'salesTransactions': (salesCount.first['total'] ?? 0) as int,
      'deliveryTransactions': (deliveryCount.first['total'] ?? 0) as int,
      'pendingTransactions': (pendingCount.first['total'] ?? 0) as int,
      'pendingBalance': await getPendingBalance(),
    };
  }
}
