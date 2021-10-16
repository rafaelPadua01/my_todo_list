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

  final formKey = GlobalKey<FormState>();
  final group_name_controller = TextEditingController();

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

  //Metodo que cria o alert com o form para edição do nome do grupo
  Future<void> _showDialogUpdate(value) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("${value.name} Editar ?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextFormField(
                      //title: const Text('insira um novo nome para este grupo'),
                      controller: group_name_controller,
                      decoration: InputDecoration(hintText: "${value.name}")),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton.icon(
                  icon: Icon(Icons.close_sharp),
                  label: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              TextButton.icon(
                  icon: const Icon(Icons.save_alt_sharp),
                  label: const Text('Save'),
                  onPressed: () {
                    //Navigator.of(context).pop();
                    Navigator.pop(context, 'Ok');
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Editando, aguarde...")));

                    updateGroup(value);
                  })
            ],
          );
        });
  }

  //Metodo que cria um alert de confirmação para remover os grupos
  Future<void> _showDialogDelete(value) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("${value.name} Remove ?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Do you really accept remove this group ?'),
                  Text(
                      'on click in "Approve" button this group going to be removed permaterly'),
                  Text('To cancel click "Close" button'),
                ],
              ),
            ),
            actions: <Widget>[
              //Cancel Button
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              //Approve Button
              TextButton(
                child: const Text('Approve'),
                onPressed: () {
                  // final id = item.id;
                  _delete(value.id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _updateGroup(Groups group) async {
    final db = await this.handler_groups.initializeDb();
    //está variavel guardara o resultado da alteração
    var result = await db.update('groups', group.toMap(),
        where: "id = ?", whereArgs: [group.id]);
    return;
  }

  Future<int> _delete(int id) async {
    final db = await this.handler_groups.initializeDb();

    return await this.handler_groups.deleteGroup(id);
  }

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
                          onLongPress: () {
                            Scaffold.of(context)
                                .showBottomSheet<void>((BuildContext context) {
                              return Container(
                                height: 200,
                                alignment: Alignment.center,
                                //color: Colors.deepPurpleAccent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    //const Text('Ações...'),
                                    //Botão rename
                                    TextButton.icon(
                                        icon: const Icon(Icons
                                            .drive_file_rename_outline_sharp),
                                        label: const Text('Rename'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showDialogUpdate(value);
                                        }),
                                    //Botão delete
                                    TextButton.icon(
                                        icon: const Icon(Icons.delete_forever),
                                        label: const Text('Delete'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showDialogDelete(value);
                                        }),
                                    TextButton.icon(
                                        icon: const Icon(Icons.close_sharp),
                                        label: const Text('Close Bottom Sheet'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        }),
                                  ],
                                ),
                              );
                            });
                            //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //      content: Text('Janela de opções dos cards')));
                          },
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
                              color: Colors.indigoAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            //color: Colors.blueGrey.shade900,
                            //alignment: Alignment.center,
                            margin: EdgeInsets.all(8),
                            child: Text(
                              'name: ${value.name}',
                              style: TextStyle(color: Colors.grey[50]),
                            ),
                          ));
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
        });
  }

//Gera as linhas para a lista em cards separados
  Widget _buildRowList(items) {
    return Card(
      child: Column(
        children: [
          //Cria header para listas de grupos
          // se data == data atual, exibir como 'hoje'
          //se não exibe a data em que foi criado
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

  //Metodo update que recebe os novos dados
  // armazena nos campos corretos e manda para o back-end
  void updateGroup(value) {
    setState(() {
      if (value != null || value.id >= 0) {
        value = Groups(
          id: value.id,
          name: group_name_controller.text,
          create_at: value.create_at,
          update_at: DateTime.now().toString(),
        );
        _updateGroup(value);
      } else {
        print('erro');
      }
    });
  }
}
