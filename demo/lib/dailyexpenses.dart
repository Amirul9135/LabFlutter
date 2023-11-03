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

  void _addExpense() async {
    String description = descController.text.trim();
    String amount = amountController.text.trim();
    totalAmount += double.parse(amount);
    if (description.isNotEmpty && amount.isNotEmpty) {
      setState(() {
        expenses.add(Expense(amount, description));
        descController.clear();
        amountController.clear();
        totalAmountController.text = totalAmount.toString();
      });
    }
  }

  void _removeExpense(int index) {
    totalAmount -= double.parse(expenses[index].amount);
    setState(() {
      expenses.removeAt(index);
      totalAmountController.text = totalAmount.toString();
    });
  }

  // Navigate to Edit Screen
  void _editExpense(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditExpenseScreen(
          expense: expenses[index],
          onSave: (editedExpense) {
            setState(() {
              totalAmount += double.parse(editedExpense.amount) -
                  double.parse(expenses[index].amount);
              expenses[index] = editedExpense;
              totalAmountController.text = totalAmount.toString();
            });
          },
        ),
      ),
    );
  }

  void _save() async {
    //test add 
    RequestController req1 = RequestController(path: "/api/Time/current/zone?timeZone=Asia/Kuala_Lumpur", server: "https://timeapi.io");
    await req1.get();
    print(req1.result());

    RequestController req = RequestController(path: "/api/test.php?username=${widget.username}");
    
    req.setBody({
      "data": expenses
    });
    await req.post();
    print(req.status());
    print(req.result());
    // test add end
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build 
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome to stupib Flutter ${widget.username}"),
        ),
      );
    });

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
          ElevatedButton(
            onPressed: _save,
            child: Text('Save'),
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
            key: Key(expenses[index].amount), // Unique key for each item
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
    amountController.text = expense.amount;

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
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (RM)',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(Expense(amountController.text, descController.text));
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
  String amount;
  Expense(this.amount, this.desc);
    Map<String, dynamic> toJson() => {
        'desc': desc,
        'amount': amount,
      };
}
