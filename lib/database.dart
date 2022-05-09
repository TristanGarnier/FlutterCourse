import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'expense.dart';

class SQLiteDbProvider{
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static late Database _database;
  Future<Database> get database async{
    if(_database != null){
      return _database;
    } else {
      _database = await initDB();
      return _database;
    }
  }
  initDB() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "expense.db");
    return await openDatabase(path, version: 1, onOpen: (db){}, onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE expense ( id INTEGER PRIMARY KEY, montant REAL, date TEXT, category Text)');
      await db.execute('INSERT INTO expense (id, montant, date, category) Values (?,?,?,?)',[1, 100, "2001-01-01", "food"]);
    });
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    List<Map> result = await db.query("expense", columns: Expense.columns, orderBy: 'date DESC');
    List<Expense> expenses = [];
    result.forEach((element) {
      // Expense element = Expense.fromMap(element)
      expenses.add(Expense.fromMap(element));
    });
    return expenses;
  }

  Future<Expense?> getExpenseById(int id) async {
    final db = await database;
    var result = await db.query("expense", where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Expense.fromMap(result.first) : null;
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    List<Map> list = await db.rawQuery('SELECT SUM(montant) From expense');
    return list.isNotEmpty ? list.first['SUM(montant)'] : null;
  }

  Future<Expense> insertExpense(Expense expense) async {
    final db = await database;
    var maxIdResult = await db.rawQuery('SELECT MAX(id)+1 AS last_insert_id from expense');
    var id = int.parse(maxIdResult.first['last_insert_id'].toString());
    var result = await db.rawInsert('INSERT INTO expense (id, montant, date, category) Values (?,?,?,?)',[id, expense.montant, expense.date, expense.category]);
    return Expense(id.toInt(), expense.montant, expense.date, expense.category);
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete("expense", where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    var result = await db.update("expense", expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
    return result;
  }
}