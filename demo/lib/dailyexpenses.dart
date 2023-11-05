import 'package:demo/Model/expense.dart';
import 'package:demo/Controller/request_controller.dart'; 
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
  final TextEditingController txtDateController = TextEditingController(); //new
  double totalAmount = 0;

  //edited
  void _addExpense() async {
    String description = descController.text.trim();
    String amount = amountController.text.trim();
    if (amount.isNotEmpty && description.isNotEmpty) {
      Expense exp =
          Expense(double.parse(amount), description, txtDateController.text);
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
  _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedDate != null && pickedTime != null) {
      setState(() {
        txtDateController.text =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day} ${pickedTime.hour}:${pickedTime.minute}:00";
      });
    }
  }

  //new
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _showMessage("Welcome ${widget.username}");
      
      RequestController req = RequestController(
          path: "/api/Time/current/zone?timeZone=Asia/Kuala_Lumpur",
          server: "https://timeapi.io");
      req.get().then((value) {
        dynamic res = req.result();
        txtDateController.text =
            "${res["year"]}-${res["month"]}-${res["day"]} ${res["hour"]}:${res["minute"]}:${res["seconds"]}";
      });
      expenses.addAll(await Expense.loadAll());

      setState(() {
        calculateTotal();
      });
    });
  }

  //edited
  @override
  Widget build(BuildContext context) { 
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
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (RM)'),
            ),
          ),
          Padding(
            //new
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.datetime,
              controller: txtDateController,
              readOnly: true,
              onTap: _selectDate,
              decoration:const InputDecoration(labelText: 'Date'),
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
                subtitle: Row(children: [
                  //edited
                  Text('Amount: ${expenses[index].amount}'),
                  const Spacer(),
                  Text('Date: ${expenses[index].dateTime}')
                ]),
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


