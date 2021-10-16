import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/database_helper.dart';
import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter/scheduler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_application_1/notifications/notifications_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ListTodo extends StatefulWidget {
  @override
  _ListTodoState createState() => _ListTodoState();
}

class _ListTodoState extends State<ListTodo> {
  late DatabaseHandler handler;

  DateTime? _dateInit;
  TimeOfDay? _initialTime;
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial;
  String? cancelText;
  String? confirmText;

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    handler = DatabaseHandler();
    handler.initializeDb().whenComplete(() async {
      setState(() {
        todos();
        //ReceiveItensNotification();
      });
    });
  }

  //Metodo q  ue cria a lista com tods as tarefas
  Future<List<Todo>> todos() async {
    final db = await this.handler.initializeDb();

    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      //print(maps);
      return Todo(
        id: maps[i]['id'],
        description: maps[i]['description'],
        checked: maps[i]['checked'],
        date: maps[i]['date'],
        time: maps[i]['time'],
        fk_id_group: maps[i]['fk_id_group'],
      );
    });
  }

  Future<void> _updateTodo(Todo todos) async {
    final db = await this.handler.initializeDb();
    var result = await db
        .update('todos', todos.toMap(), where: "id = ?", whereArgs: [todos.id]);
    return;
  }

  Future<void> _updateChecked(Todo todos, int id, int item_checked) async {
    final db = await this.handler.initializeDb();
    final checked = item_checked;
    var result = await db
        .update('todos', todos.toMap(), where: "id = ?", whereArgs: [todos.id]);
    return;
  }

  //método delete
  Future<int> _delete(int id) async {
    final db = await this.handler.initializeDb();

    // retorna o metodo delete ddemtro do handler
    return await this.handler.deleteTodo(id);
  }

  //Metodo que recebe a lista de itens retornados e faz o envio das notificações
  /*
  @override
  void _sendNotification(item) async {
    final send = await NotificationService().showNotification(
        item['id'],
        'Alerta agendado.',
        'Você agendou uma terefa ${item['description']}',
        5);
    return send;
  }
*/
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: this.handler.todos(),
          builder:
              (BuildContext contex, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = snapshot.data![index];
                    bool _checked = (item.checked < 1) ? false : true;
                    //mapeia a lista para uma variavel
                    //List<Todo> _items = this.handler.todos();

                    return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          setState(() {
                            //retorna o metodo delete
                            _delete(item.id);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  '${item.description} foi removido com sucesso...')));
                        },
                        background: Container(color: Colors.indigoAccent),
                        child: Card(
                          child: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return Center(
                              child: CheckboxListTile(
                                title: Text(item.description),
                                subtitle: Text(
                                    'Data : ' + item.date.substring(0, 10).toString() + "/" + 'Hora: ' + item.time.substring(10,  15)),
                                activeColor: Colors.blue,
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.platform,
                                value: _checked,
                                selected: _checked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _checked = value!;

                                    itemChanged(
                                        item.checked, _checked, index, item);
                                  });

                                  // exibe o item com uma mensagem de checado
                                },
                                //Botão editar todos
                                secondary: TextButton(
                                  child: Text('editar'),
                                  onPressed: () {
                                    setState(() {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            //props do alert
                                            AlertDialog(
                                          title: Text(item.description),
                                          content: Form(
                                            key: _formKey,
                                            child: Column(
                                              children: <Widget>[
                                                TextFormField(
                                                    controller: _description,
                                                    decoration: InputDecoration(
                                                      border:
                                                          UnderlineInputBorder(),
                                                      labelText:
                                                          item.description,
                                                    ),
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'please enter some Text';
                                                      }
                                                      return null;
                                                    }),
                                                /*Text(_dateInit == null
                                                    ? 'Nothing has been picked yet'
                                                    : _dateInit.toString()), */
//DatePicker
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    border:
                                                        UnderlineInputBorder(),
                                                    labelText: _dateInit == null
                                                        ? 'Entre com a data'
                                                        : _dateInit.toString(),
                                                  ),
                                                  onTap: () {
                                                    showDatePicker(
                                                      context: context,
                                                      initialDate:
                                                          DateTime.now(),
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
                                                    border:
                                                        UnderlineInputBorder(),
                                                    labelText:
                                                        _initialTime == null
                                                            ? 'Entre com a hora'
                                                            : _initialTime
                                                                .toString(),
                                                  ),
                                                  onTap: () {
                                                    showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now(),
                                                      initialEntryMode:
                                                          initialEntryMode,
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
                                              ],
                                            ),
                                          ),
                                          //timePicker

                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                //Valida retorno true se  form for validado,
                                                //ou false
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  updateTodo(item);
                                                  Navigator.pop(context, 'Ok');
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "Editando, aguarde...")));
                                                }
                                              },
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        ),
                                      );
                                      child:
                                      const Text('show dialog');
                                    });
                                  },
                                ),
                              ),
                            );
                          }),
                        ));
                  });
            } else {
              return Center(child: Text('Nenhuma tarefa encontrada'));
            }
          }),
    );
  }

  void updateTodo(item) {
    setState(() {
      if (item != null || item.id >= 0) {
        item = Todo(
          id: item.id,
          description: _description.text,
          checked: item.checked,
          date: _dateInit.toString(),
          time: _initialTime.toString(),
          fk_id_group: item.fk_id_group,
        );
        _updateTodo(item);
        //print('$item');
      } else {
        print('erro');
      }
    });
  }

  @override
  void itemChanged(int item_checked, bool _checked, int index, item) {
    setState(() {
      if (_checked) {
        item_checked = 1;
        int id = index;
        item = Todo(
          id: item.id,
          description: item.description,
          checked: item_checked,
          date: item.date,
          time: item.time,
          fk_id_group: item.fk_id_group,
        );
        _updateChecked(item, id, item_checked);
      } else {
        item_checked = 0;
        int id = index;
        item = Todo(
          id: item.id,
          description: item.description,
          checked: item_checked,
          date: item.date,
          time: item.time,
          fk_id_group: item.fk_id_group,
        );
        _updateChecked(item, id, item_checked);
      }
      return;
      //item.id.checked = value;
    });
  }
}
