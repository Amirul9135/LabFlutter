import 'package:demo/Controller/sqlite_db.dart';
import 'package:demo/Model/expense.dart'; 

class ExpenseDB{ 
  
  final SQLiteDB _db = SQLiteDB();
  final String tableName = "expenses";
  
  ExpenseDB._();
  static final ExpenseDB _instance = ExpenseDB._();
 

  factory ExpenseDB()  {
    return _instance;
  }

  Future<int> insert(Expense exp) async {
    return _db.insert(tableName, exp.toJson());
  }

  Future<int> update(Expense exp) async {
    return _db.update(tableName, 'id', exp.toJson());
  }

  Future<List<Expense>> loadAll() async {
    List<Map<String,dynamic>> result = await _db.queryAll(tableName);
    List<Expense> expenses = [];
    for(dynamic item in result){
      expenses.add(Expense.fromJson(item));
    }

    return expenses;
  }

  Future<int> delete(Expense exp) async{
    return _db.delete(tableName, 'id', exp.id);
  }
  
   
}