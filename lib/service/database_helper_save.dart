import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/model/save_model.dart';
import 'database_helper.dart';

class DatabaseHandlerSave {
  //herda os atributos da classe DABASEHANDLEr
  final handler = new DatabaseHandler();
  //Inicia a conexão com banco de ddados
  Future<Database> initializeDb() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'todo.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE save(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,'
          'fk_id_todo INTEGER NOT NULL, fk_description TEXT NOT NULL, '
          'fk_checked TEXT NOT NULL, fk_date TEXT NOT NULL, fk_time TEXT NOT NULL , '
          'create_at TEXT NOT NULL, update_at TEXT, FOREIGN KEY (fk_id_todo) references todos(id) ,'
          'FOREIGN KEY (fk_description) references todos(description) ,'
          'FOREIGN KEY (fk_checked) references todos(checked) ,'
          'FOREIGN KEY (fk_date) references todos(date) ,'
          'FOREIGN KEY (fk_time) references todos(time))',
        );
      },
      version: 1,
    );
  }

  //Metodo que insere os todos salvos
  Future<int> saveTodo(List<Save> items) async {
    //conecta com o banco de dados
    final db = await initializeDb();

    int result = 0;

    for (var item in items) {
      result = await db.insert(
        'save',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      int? id = item.fk_id_todo;

      return await this.handler.deleteTodo(id);
    }

    return result;
  }

  //MEtodo que lista os saves
  Future<List<Save>> saves() async {
    //Conecta com banco e recebe as referencias
    final db = await initializeDb();
    //consulta a table por todos os saves
    final List<Map<String, dynamic>> maps = await db.query('save');

    return List.generate(maps.length, (i) {
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
  }

  //Lista saves apartir dos respectivos fk_id_groups
  //para que sejam exibidos corretamente na lista dos grupos
  /*
  Future<List<Save>> savesGroups() async {
    final db = await initializeDb();

    final List<Map<String, dynamic>> maps =
        await db.rawQuery('select * from saves where fk_id_group = id');
    return List.generate(maps.length, (i) {
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
  }*/
}
