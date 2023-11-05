import 'package:demo/request_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//void main(){runApp(DailyExpensesApp(username: ""));}

class DailyExpensesApp extends StatelessWidget {
  final String username;
  DailyExpensesApp({required String this.username});

  //const DailyExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ExpenseList(username: username),
    );
  }
}

class ExpenseList extends StatefulWidget {
  final String username;
  ExpenseList({required this.username});
  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  final List<Expense> expenses = [];
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  double totalAmount = 0;

  //edited
  void _addExpense() async {
    String description = descController.text.trim();
    String amount = amountController.text.trim();
    if (amount.isNotEmpty && description.isNotEmpty) {
      RequestController req = RequestController(
          path: "/api/Time/current/zone?timeZone=Asia/Kuala_Lumpur",
          server: "https://timeapi.io");
      await req.get();
      // only proceed if status code is 200 == success
      if (req.status() == 200) {
        dynamic res = req.result();
        String dateTime =
            "${res["year"]}-${res["month"]}-${res["day"]} ${res["hour"]}:${res["minute"]}:${res["seconds"]}";
        Expense exp = Expense(double.parse(amount), description, dateTime);
        if (await exp.save()) {
          setState(() {
            expenses.add(exp);
            descController.clear();
            amountController.clear();
            calculateTotal();
          });
        } else {
          _showMessage("Failed to save Expenses data");
        }
      } else {
        _showMessage("Failed to load current time");
      }
    }
  }

  //new
  void calculateTotal() {
    totalAmount = 0;
    for (Expense ex in expenses) {
      totalAmount += ex.amount;
    }
    totalAmountController.text = totalAmount.toString();
  }

  void _removeExpense(int index) {
    totalAmount -= expenses[index].amount;
    setState(() {
      expenses.removeAt(index);
      totalAmountController.text = totalAmount.toString();
    });
  }

  //new
  void _showMessage(String msg) {
    if (mounted) {
      //make sure this context is still mounted/exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
        ),
      );
    }
  }

  // Navigate to Edit Screen
  //edited
  void _editExpense(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) {
            setState(() {
              totalAmount += editedExpense.amount - expenses[index].amount;
              expenses[index] = editedExpense;
              totalAmountController.text = totalAmount.toString();
            });
          },
        ),
      ),
    );
  }

  //new
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _showMessage("Welcome to stupib Flutter ${widget.username}");
      expenses.addAll(await Expense.loadAll());
      setState(() {
        calculateTotal();
      });
    });
  }

  //edited
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //moved message to init()

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Expenses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount (RM)'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: totalAmountController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Total Spend (RM):'),
            ),
          ),
          ElevatedButton(
            onPressed: _addExpense,
            child: Text('Add Expense'),
          ),
          Container(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          // Unique key for each item
          return Dismissible(
            key: Key(
                expenses[index].amount.toString()), // Unique key for each item
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            onDismissed: (direction) {
              // Handle item removal here
              _removeExpense(index);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Item dismissed')));
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(expenses[index].desc),
                subtitle: Text('Amount: ${expenses[index].amount}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeExpense(index),
                ),
                onLongPress: () {
                  _editExpense(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// Second Screen for editing Daily Expenses details.
class EditExpenseScreen extends StatelessWidget {
  final Expense expense;
  final Function(Expense) onSave;

  EditExpenseScreen({required this.expense, required this.onSave});

  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    descController.text = expense.desc;
    amountController.text = expense.amount.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //edited
              onSave(Expense(double.parse(amountController.text),
                  descController.text, expense.dateTime));
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class Expense {
  String desc;
  double amount;
  String dateTime;
  Expense(this.amount, this.desc, this.dateTime);

  Expense.fromJson(Map<String, dynamic> json)
      : desc = json['desc'] as String,
        amount = (json['amount'] as dynamic)
            .toDouble(), //sometime dart assume non decimal number as int and can't cast it to double auto. so take it as dynamic and cast to double
            // json string value 10 will be treated as int 10 and can't be assigned into double
        dateTime = json['dateTime'] as String;

  // toJson will be automatically called by jsonEncode when necessary
  Map<String, dynamic> toJson() =>
      {'desc': desc, 'amount': amount, 'dateTime': dateTime};

  Future<bool> save() async {
    RequestController req = RequestController(path: "/api/expenses.php");
    req.setBody(toJson());
    await req.post();
    if (req.status() == 200) {
      return true;
    }
    return false;
  }

  static Future<List<Expense>> loadAll() async {
    List<Expense> result = [];
    RequestController req = RequestController(path: "/api/expenses.php");
    await req.get();
    if (req.status() == 200 && req.result() != null) {
      for (var item in req.result()) {
        result.add(Expense.fromJson(item));
      }
    }
    return result;
  }
}
