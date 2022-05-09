import 'dart:collection';
import 'package:scoped_model/scoped_model.dart';
import 'expense.dart';
import 'database.dart';

class ExpenseListModel extends Model{
  ExpenseListModel(){
    load();
  }

  final List<Expense> _expense = [];
  UnmodifiableListView<Expense> get expenses => UnmodifiableListView(_expense);

  void load(){
    Future<List<Expense>> expenses = SQLiteDbProvider.db.getAllExpenses();
    expenses.then((dbItems) {
      for(var i = 0; i < dbItems.length; i++){
        _expense.add(dbItems[i]);
      }
      notifyListeners();
    });
  }

  Future<double> get totalExpenses async {
    return await SQLiteDbProvider.db.getTotalExpenses();
  }

  Future<Expense?> byId(int id) async{
    return await SQLiteDbProvider.db.getExpenseById(id);
  }

  void insertExpense(Expense expense) async{
    await SQLiteDbProvider.db.insertExpense(expense).then((val){
      _expense.add(val);
      notifyListeners();
    });
  }

  void updateExpense(Expense expense) async{
    await SQLiteDbProvider.db.updateExpense(expense).then((val) {
      var index = _expense.indexWhere((element) => element.id == expense.id);
      _expense[index] = expense;
      notifyListeners();
    });
  }

  void deleteExpense(Expense expense) async{
    await SQLiteDbProvider.db.deleteExpense(expense.id).then((val) {
      _expense.removeWhere((element) => element.id == expense.id);
      notifyListeners();
    });
  }
}