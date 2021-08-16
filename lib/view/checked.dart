import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/database_helper.dart';
import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter_application_1/model/save_model.dart';
import 'package:flutter_application_1/service/database_helper_save.dart';

class ListChecked extends StatefulWidget {
  const ListChecked({Key? key}) : super(key: key);
  @override
  _ListCheckedState createState() => _ListCheckedState();
}

class _ListCheckedState extends State<ListChecked> {
  late DatabaseHandler handler;
  late DatabaseHandlerSave handler_save;

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler_save = DatabaseHandlerSave();
    this.handler.initializeDb().whenComplete(() async {
      setState(() {
        // todos();
      });
    });
  }

  //Metodo que recebe os todos e gera lista
  /*
  Future<List<Todo>> todos() async {
    //conecta ao banco de dados e recebe as refencias do mesmo
    final db = await this.handler.initializeDb();

    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        description: maps[i]['description'],
        checked: maps[i]['checked'],
        date: maps[i]['date'],
        time: maps[i]['time'],
      );
    });
  }*/

  //Metodo que salva os item que foram concluidos
  //é necwessario clicar no botão save
  //ele enviara para o model
  // que fará todo o trabalho para nós
  Future<int> saveTodo(list_item) async {
    int result = 0;
    final items = list_item;
    final date_time = DateTime.now();
    for (var item in items) {
      Save insertSave = Save(
        fk_id_todo: item.id,
        fk_description: item.description,
        fk_checked: item.checked,
        fk_date: item.date,
        fk_time: item.time,
        fk_id_group: item.fk_id_group,
        create_at: date_time.toString(),
      );

      final insert = await this.handler_save.saveTodo([insertSave]);
      //return insert;
      // return insert;
    }
    //print(items);
    /*for (var i = 0; i < items.length; i++) {
      var item = items[i];
      print(item);
      Save insertSave = Save(
        fk_id_todo: item.id,
        fk_description: item.description,
        fk_checked: item.checked,
        fk_date: item.date,
        fk_time: item.time,
        create_at: date_time.toString(),
      );
      //Cria a lista que recebera todos os todos
      List<Save> listOfSave = [insertSave];
      //print(item);
//      result = 1;
//      print(listOfSave);

      return await this.handler_save.saveTodo(listOfSave);
      // print(item.description);
    }*/
    //  List<Save> listOfSave = items;

    // print(listOfSave);
    /*Map<String, Object?> mapListOfSave = {
      fk_id_todo: items.id,
      fk_description: items.description,
      fk_checked: items.checked,
      fk_date: items.date,
      fk_time: items.time,
      create_at: date_time.toString(),
    };
    */
    //return await this.handler_save.saveTodo(listOfSave);

    // ScaffoldMessenger.of(context)
    //    .showSnackBar(SnackBar(content: Text('Itens sendo salvos...')));
    return result;
  }

  void _save() async {
    final db = await this.handler.initializeDb();
    final List<Map<String, dynamic>> maps = await db.query('todos');

    final list_item = List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        description: maps[i]['description'],
        checked: maps[i]['checked'],
        date: maps[i]['date'],
        time: maps[i]['time'],
        fk_id_group: maps[i]['fk_id_group'],
      );
    });
    setState(() {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Itens sendo salvos...')));
      //print(list_item);
      saveTodo(list_item);
      return;
    });
    //final listOfItem = items;
  }

  //interface que carrega a lista de tgodos feitos
  // e toda a parte de interface grafica desta classe
//Este é o novo widget que espero que funcione :D
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(child: _buildListItem()),
            Center(child: _buildButtomSave()),
          ],
        ),

        //child: _buildButtomSave(),
      ),
    );
  }

  Widget _buildListItem() {
    return FutureBuilder(
        future: this.handler.todos(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext contex, int index) {
                final item = snapshot.data![index];
                var _checked = item.checked;

                _checked = Card(child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return _buildRowItem(item);
                }));

                return _buildRowItem(item);
              },
            );
          } else {
            return Center(child: Text('Nenhuma tarefa encontrada'));
          }
        });
  }

  Widget _buildRowItem(item) {
    return Card(
      child: ListTile(
        title: Text(item.description),
        subtitle: Text((item.checked == 1) ? 'concluido' : 'não concluido'),
        selected: (item.checked == 1) ? true : false,
      ),
    );
  }

  Widget _buildButtomSave() {
    return ElevatedButton(
        child: Text('Save List'),
        onPressed: () {
          final items = this.handler.todos();
          //print(items);
          _save();
        });
  }
}
