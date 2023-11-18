//import 'package:demo/Controller/request_controller.dart';
import 'package:demo/Controller/sqlite_db.dart';

class Expense {
  static const String SQLiteTable = "expense";
  int? id;
  String desc;
  double amount;
  String dateTime;
  Expense(this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
      : desc = json['desc'] as String,
        amount = (json['amount'] as dynamic)
            .toDouble(), 
        dateTime = json['dateTime'] as String,
        id = json['id'] as int?;

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
      {'desc': desc, 'amount': amount, 'dateTime': dateTime};

  Future<bool> save() async {
    try{
      await SQLiteDB().insert(SQLiteTable, toJson());
      return true;
    }catch(e){
      return false;
    }
   /* 
   API Operation
   RequestController req = RequestController(path: "/api/expenses.php");
    req.setBody(toJson());
    await req.post();
    if (req.status() == 200) {
      return true;
    }
    return false;*/
  }

  static Future<List<Expense>> loadAll() async {

    
    List<Map<String,dynamic>> result = await SQLiteDB().queryAll(SQLiteTable);
    List<Expense> expenses = [];
    for(dynamic item in result){
      expenses.add(Expense.fromJson(item));
    }

    return expenses;

    /*
    API Operation
    List<Expense> result = [];
    RequestController req = RequestController(path: "/api/expenses.php");
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(Expense.fromJson(item));
      }
    }
    return result;*/
  }
}
