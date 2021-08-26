import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/database_helper_save.dart';
import 'package:flutter_application_1/service/database_helper_group.dart';
import 'package:flutter_application_1/model/group_model.dart';
import 'package:flutter_application_1/model/save_model.dart';

class GridGroups extends StatefulWidget {
  const GridGroups({Key? key}) : super(key: key);

  @override
  State<GridGroups> createState() => _GridGroupsState();
}

class _GridGroupsState extends State<GridGroups> {
  late DatabaseHandlerSave handler_save;
  late DatabaseHandlerGroups handler_groups;

  @override
  //estado inicial do app
  void initState() {
    super.initState();
    this.handler_save = DatabaseHandlerSave();
    this.handler_groups = DatabaseHandlerGroups();
    this.handler_groups.initializeDb().whenComplete(() async {
      setState(() {
        //print(list_items);
      });
    });
  }

//Metodo que gera as listas para o DropdownItems
  Future _getAllGroups() async {
    final db = await this.handler_groups.initializeDb();
    final List<Map<String, dynamic>> maps = await db.query('groups');
    final items = List.generate(maps.length, (i) {
      return Groups(
        id: maps[i]['id'],
        name: maps[i]['name'],
        create_at: maps[i]['create_at'],
        update_at: maps[i]['update_at'],
      );
    });

    // return getAllTodos(items);
  }

  //MEtodo que recebe os todos
  /*
  Future getAllTodos(items) async {
    final db = await this.handler_save.initializeDb();
    final List<Map<String, dynamic>> maps = await db.query('saves');
    final item = List.generate(maps.length, (i) {
      return Save(
        id: maps[i]['id'],
        fk_id_todo: maps[i]['fk_id_todo'],
        fk_id_group: maps[i]['fk_id_group'],
        fk_description: maps[i]['fk_description'],
        fk_checked: maps[i]['fk_checked'],
        fk_date: maps[i]['fk_date'],
        fk_time: maps[i]['fk_time'],
        create_at: maps[i]['create_at'],
      );
    });

    for (var group in items) {
      for (var list in item) {
        if (list.fk_id_group == group.id) {
          var value = list;
          return _buildList(value);
        } else {
          return Center(child: Text('lista Vazia....'));
        }
      }
    }
  }
*/
  @override
  //Build que carrega a interface
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
          future: this.handler_groups.groups(),
          builder:
              (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
            final item = snapshot.data!;
            if (snapshot.hasData) {
              return GridView.count(
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: (2 / 1),
                  children: item.map(
                    (value) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(value.name + ' Grupos de listas'),
                              ),
                              body: Column(
                                children: [
                                  Expanded(child: _buildList(value)),
                                ],
                              ),
                            );
                          }));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          //color: Colors.deepPurpleAccent,
                          //alignment: Alignment.center,
                          margin: EdgeInsets.all(8),
                          child: Text('name: ${value.name}'),
                        ),
                      );
                    },
                  ).toList());
            } else {
              return Center(child: Text('Nenhum grupo criado...'));
            }
          }),
    );
  }

//gera a lista para ser enviada ao widget principal
  Widget _buildList(value) {
    return FutureBuilder(
        future: this.handler_save.saves(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          final item = snapshot.data!;
          var items;
          //print(value);
          // if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (BuildContext context, int index) {
                items = snapshot.data?[index];
                if (snapshot.hasData && items.fk_id_group == value.id) {
                  return _buildRowList(items);
                } else {
                  return const SizedBox();
                }
              });

          //print(items);
          //return _buildRowList(items);
          //} else {
          //return Center(child: Text('Lista Vazia...'));
          //}

          // return value;
        });
  }

//Gera as linhas para a lista em cards separados
  Widget _buildRowList(items) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(items.fk_description),
            subtitle:
                Text((items.fk_checked == 1) ? 'concluido' : 'não concluido'),
            selected: (items.fk_checked == 1) ? true : false,
          ),
        ],
      ),
    );
  }
}
