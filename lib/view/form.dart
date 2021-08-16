import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/database_helper.dart';
import 'package:flutter_application_1/service/database_helper_group.dart';
import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter_application_1/model/group_model.dart';

class FormTodo extends StatefulWidget {
  const FormTodo({Key? key}) : super(key: key);

  @override
  _FormTodoState createState() => _FormTodoState();
}

class _FormTodoState extends State<FormTodo> {
  late DatabaseHandler handler;
  late DatabaseHandlerGroups handler_group;

  DateTime? _dateInit;
  TimeOfDay? _initialTime;
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial;
  String? cancelText;
  String? confirmText;
  String? selectedGroup;
  //List list_items = ['teste0', 'teste1', 'teste2']; //<Groups>[];

  final _description = TextEditingController();
  final _selectedGroup = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  //estado inicial do app
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler_group = DatabaseHandlerGroups();
    handler.initializeDb().whenComplete(() async {
      setState(() {
        //print(list_items);
      });
    });
  }

  //Metodo que gera as listas para o DropdownItems
  Future _getAllGroups() async {
    final db = await this.handler.initializeDb();
    final List<Map<String, dynamic>> maps = await db.query('groups');
    final items = List.generate(maps.length, (i) {
      return Groups(
        id: maps[i]['id'],
        name: maps[i]['name'],
        create_at: maps[i]['create_at'],
        update_at: maps[i]['update_at'],
      );
    });
  }

  //Metodo que é acionado pleo botão do form
  Future<int> addTodo(selected_id) async {
    int checked = 0;
    int id_selected = int.parse(selected_id);
    //print(id_selected);
    Todo insertTodo = Todo(
      description: _description.text,
      checked: checked,
      date: _dateInit.toString(),
      time: _initialTime.toString(),
      fk_id_group: id_selected,
    );

    List<Todo> listOfTodos = [insertTodo];
    return await this.handler.insertTodo(listOfTodos);
  }

  //limpa o state da app
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _submit(selectedGroup) {
    final db = this.handler.initializeDb();
    final form = _formKey.currentState;
    final selected_id = selectedGroup;
    setState(() {
      addTodo(selected_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<dynamic>>(
            future: this.handler_group.groups(),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                final item = snapshot.data!;
                return Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                          controller: _description,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Entre com a tarefa',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'por favor entre com uma tarefa';
                            }

                            return null;
                          }),
                      SizedBox(
                        height: 10.0,
                      ),
                      //Botão select dos grupos.
                      DropdownButton(
                        //  controller: _selectedGroup,
                        hint: Text('Select Group'),
                        //value: selectedGroup,
                        icon: const Icon(Icons.arrow_downward),
                        style: const TextStyle(color: Colors.deepPurple),

                        items: item.map((valueItem) {
                          return DropdownMenuItem(
                            value: valueItem.id,
                            child: Text(valueItem.name.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGroup = value.toString();
                          });
                        },
                      ),
                      /*
          InputDatePickerFormField(
              //context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime(2050),
              onDateSubmitted: (date) {
                setState:
                (() {
                  _dateInit = date;
                });
              }),*/
                      //datepicker

                      /*Text(_dateInit == null
              ? 'Nothing has been picked yet'
              : _dateInit.toString()),*/
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: _dateInit == null
                              ? 'Entre com a data'
                              : _dateInit.toString(),
                        ),
                        onTap: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2001),
                            lastDate: DateTime(2022),
                          ).then((date) {
                            setState(() {
                              _dateInit = date;
                            });
                          });
                        },
                      ),
                      //TimePicker
                      TextFormField(
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: _initialTime == null
                              ? 'Entre com a hora'
                              : _initialTime.toString(),
                        ),
                        onTap: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: initialEntryMode,
                            cancelText: cancelText,
                            confirmText: confirmText,
                          ).then((time) {
                            setState(() {
                              if (time != null) {
                                _initialTime = time;
                              }
                            });
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Nova Tarefa Salva...')));
                            return _submit(selectedGroup);
                          }
                        },
                        child: Text('Submit'),
                      )
                    ],
                  ),
                );
              } else {
                return Center(child: Text('Lista vazia...'));
              }
            }));
  }
}
