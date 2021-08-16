import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/database_helper_group.dart';
import 'package:flutter_application_1/model/group_model.dart';

class GridGroups extends StatefulWidget {
  const GridGroups({Key? key}) : super(key: key);

  @override
  State<GridGroups> createState() => _GridGroupsState();
}

class _GridGroupsState extends State<GridGroups> {
  late DatabaseHandlerGroups handler_groups;

  @override
  //estado inicial do app
  void initState() {
    super.initState();
    //handler = DatabaseHandler();
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
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: Text(value.name + ' Grupos de listas'),
                              ),
                              body: Center(
                                child: Text(
                                    'Aqui vou carregar as listas que pertencem ao grupo...'),
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
}
