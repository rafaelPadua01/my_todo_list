import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/model/group_model.dart';
import 'database_helper.dart';

class DatabaseHandlerGroups {
  final handler = DatabaseHandler();
  //Metodo insert

  //Inicia a conexão com banco de ddados
  Future<Database> initializeDb() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'todo.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE groups(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
            'name TEXT NOT NULL, create_at TEXT NOT NULL, update_at TEXT)');
      },
      version: 1,
    );
  }

  // Insere um novo 'grupo'
  Future<int> saveGroup(List<Groups> items) async {
    final db = await initializeDb();
    int result = 0;

    for (var item in items) {
      result = await db.insert(
        'groups',
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    //print(result);
    return result;
  }

//metodo que lista os grupos
  Future<List<Groups>> groups() async {
    //conecta o banco e recebe as referencias
    final db = await this.handler.initializeDb();

    ////consulta a tabela por todos osn grupos
    final List<Map<String, dynamic>> maps = await db.query('groups');

    return List.generate(maps.length, (i) {
      return Groups(
        id: maps[i]['id'],
        name: maps[i]['name'],
        create_at: maps[i]['create_at'],
        update_at: maps[i]['update_at'],
      );
    });
  }

  //Metodo que remove os grupos
  Future<int> deleteGroup(int? id) async {
    final db = await initializeDb();

    return await db.delete(
      'groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
