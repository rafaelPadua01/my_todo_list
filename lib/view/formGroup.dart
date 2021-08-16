import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/database_helper.dart';
import 'package:flutter_application_1/service/database_helper_group.dart';
import 'package:flutter_application_1/model/group_model.dart';

class FormGroup extends StatefulWidget {
  const FormGroup({Key? key}) : super(key: key);

  @override
  _FormGroupState createState() => _FormGroupState();
}

class _FormGroupState extends State<FormGroup> {
  late DatabaseHandler handler;
  late DatabaseHandlerGroups handler_groups;

  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  //Inicia o estado da aplicação
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler_groups = DatabaseHandlerGroups();
    handler.initializeDb().whenComplete(() async {
      setState(() {});
    });
  }

  void _submit() {
    final db = this.handler.initializeDb();
    final form = _formKey.currentState;
    setState(() {
      addGroup();
    });
  }

  Future<int> addGroup() async {
    final create = DateTime.now();
    Groups insertGroup = Groups(
      name: _name.text,
      create_at: create.toString(),
    );

    List<Groups> listOfGroups = [insertGroup];
    //print(listOfGroups);
    return await this.handler_groups.saveGroup(listOfGroups);
  }

  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
              controller: _name,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Entre com um nome para o novo grupo...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor nomeie o grupo';
                }
                return null;
              }),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Novo grupo criado ...')));
                return _submit();
              }
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }
}
