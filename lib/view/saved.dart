import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/database_helper_save.dart';
import 'package:flutter_application_1/service/database_helper_group.dart';
import 'package:flutter_application_1/model/save_model.dart';
import 'package:flutter_application_1/model/group_model.dart';

class Saved extends StatefulWidget {
  const Saved({Key? key}) : super(key: key);
  @override
  _SavedState createState() => _SavedState();
}

class _SavedState extends State<Saved> {
  late DatabaseHandlerSave handler_save;
  late DatabaseHandlerGroups handler_group;

  @override
  void initState() {
    super.initState();
    this.handler_save = DatabaseHandlerSave();
    this.handler_group = DatabaseHandlerGroups();
    this.handler_group.initializeDb().whenComplete(() async {
      setState(() {
        this.handler_group.groups();
      });
    });
    //this.handler_save.initializeDb().whenComplete(() async {
    //  setState(() {
    //    this.handler_save.saves();
    // });
    // });
  }

  //Interface que carrega as listas salvas
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  //Widget que gera a lista a ser enviada ao buildprincipal da classe
  Widget _buildList() {
    return FutureBuilder(
        future: this.handler_save.saves(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          final item = snapshot.data!;
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  final items = snapshot.data![index];

                  return _buildRow(items);
                });
          } else {
            return Center(child: Text('Lista vazia...'));
          }
        });
  }

  Widget _buildRow(items) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(items.fk_description),
            // subtitle: Text(items.create_at),
            subtitle:
                Text((items.fk_checked == 1) ? 'concluido' : 'não concluido'),
            selected: (items.fk_checked == 1) ? true : false,
          ),
        ],
      ),
    );
  }
}
