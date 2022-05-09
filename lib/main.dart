import 'dart:math';

import 'package:flutter/material.dart';
import 'package:g4_2022_ing2_bdd_data/expense_list_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'expense.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculateur de dépense',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ScopedModelDescendant<ExpenseListModel>(
        builder: (context, child, model) {
          return ListView.separated(
              itemBuilder: (context, index) {
                if(index == 0){
                  return ListTile(
                      title: Text('Total des dépenses :' + model.totalExpenses.toString(),
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                  );
                }else{
                  index = index -1;
                  return Dismissible(
                      key: Key(model.expenses[index].id.toString()),
                      onDismissed: (direction){
                        model.deleteExpense(model.expenses[index]);
                        Scaffold.of(context).showSnackBar(SnackBar(content: (Text('Item id :' + model.expenses[index].id.toString() + ' supprimé')
                        )));
                      },
                    child: ListTile(onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          FormPage(
                            id: model.expenses[index].id,
                            expenses: model,
                          )
                      ));
                    },
                    leading: Icon(Icons.monetization_on),
                      trailing: Icon(Icons.keyboard_arrow_right),
                      title: Text(model.expenses[index].category + ': ' + model.expenses[index].montant.toString() + ' ' + model.expenses[index].formatedDate,
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),),
                    ),
                  );
                }
              },
              separatorBuilder: (context, index){
                return Divider();
          },
              itemCount: model.expenses.length);
        },
      ),
      floatingActionButton: ScopedModelDescendant<ExpenseListModel>(
        builder: (context, child, model) {
          return FloatingActionButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(
                builder: ((context) => ScopedModelDescendant<ExpenseListModel>(
                    builder: (context, child, model) {
                      return FormPage(id: 0, expenses: model);
                    })
                )));
            },
            tooltip: 'increment', child: Icon(Icons.add),
            );
          },
      )
    );
  }
}

class FormPage extends StatefulWidget {
  const FormPage({Key? key, required this.id, required this.expenses});
  final int id;
  final ExpenseListModel expenses;
  @override
  _FormPageState createState() => _FormPageState(id: id, expenses: expenses);
}

class _FormPageState extends State<FormPage> {
  _FormPageState({Key? key, required this.id, required this.expenses});
  final int id;
  final ExpenseListModel expenses;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late double _montant;
  late DateTime _date;
  late String _category;
  void _envoyer() {
    final form = _formKey.currentState;
    if(form.validate()) {
      form.save();
      if(id ==0) {
        expenses.insertExpense(Expense(0, _montant, _date, _category));
      }else{
        expenses.updateExpense(Expense(id, _montant, _date, _category))
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Déclarer ses dépenses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                style: TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: const Icon(Icons.monetization_on),
                  labelText: 'Montant : ',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (val){
                  RegExp regex = RegExp(r'^[0-9]\d*(\.\d+)?$');
                  if(!regex.hasMatch(val??'')){
                    return 'Montant Invalide';
                  }else{
                    return null;
                  }
                },
                initialValue: id == 0 ? '' : expenses.expenses[id].montant.toString(),
                onSaved: (val) => _montant = double.parse(val??''),
              ),
              // input & validation date
              TextFormField(
                style: TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: const Icon(Icons.calendar_today),
                  labelText: 'Date : ',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (val){
                  RegExp regExp = RegExp('^\\d{4}\\-(0[1-9]|1[012])\\-(0[1-9]|[12][0-9]|3[01])\$');
                  if(!regExp.hasMatch(val??'')){
                    return 'Date Invalide';
                  }else{
                    return null;
                  }
                },
                initialValue: id == 0 ? '' : expenses.expenses[id].date.toString(),
                onSaved: (val) => _date = DateTime.parse(val??''),
              ),
              //input et validation category
              TextFormField(
                style: TextStyle(fontSize: 22),
                decoration: const InputDecoration(
                  icon: const Icon(Icons.folder),
                  labelText: 'Catégorie : ',
                  labelStyle: TextStyle(fontSize: 18),
                ),
                validator: (val){
                  RegExp regex = RegExp(r'^[a-zA-Z0-9]$');
                  if(!regex.hasMatch(val??'')){
                    return 'Catégorie Invalide';
                  }else{
                    return null;
                  }
                },
                initialValue: id == 0 ? '' : expenses.expenses[id].category.toString(),
                onSaved: (val) => _category = val??'',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
