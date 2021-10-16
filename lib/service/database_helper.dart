import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_application_1/model/todo_model.dart';
import 'package:flutter_application_1/notifications/notifications_service.dart';

class DatabaseHandler {
  //Inicia a conexão com o banco de dados
  Future<Database> initializeDb() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'todo.db'),
      onCreate: (db, version) async {
        //Cria tabela grupos
        await db.execute(
            'CREATE TABLE groups(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
            'name TEXT NOT NULL, create_at TEXT NOT NULL, update_at TEXT)');
        // Cria tabela todos
        await db.execute(
          'CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,'
          'description TEXT, checked INTEGER, date TEXT, time TEXT, fk_id_group INTEGER NOT NULL,'
          'FOREIGN KEY (fk_id_group) references groups(id))',
        );
        //cria tabela Save
        await db.execute(
          'CREATE TABLE save(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,'
          'fk_id_todo INTEGER NOT NULL, fk_id_group INTEGER NOT NULL, fk_description TEXT NOT NULL, '
          'fk_checked INTEGER NOT NULL, fk_date TEXT NOT NULL, fk_time TEXT NOT NULL , '
          'create_at TEXT NOT NULL, update_at TEXT,'
          'FOREIGN KEY (fk_id_todo) references todos(id) , '
          'FOREIGN KEY (fk_id_group) references todos(fk_id_group),'
          'FOREIGN KEY (fk_description) references todos(description) ,'
          'FOREIGN KEY (fk_checked) references todos(checked) ,'
          'FOREIGN KEY (fk_date) references todos(date) ,'
          'FOREIGN KEY (fk_time) references todos(time))',
        );
      },
      version: 1,
    );
  }

  //Metodo que insere os dados na tabela
  Future<int> insertTodo(List<Todo> todos) async {
    //conecta com o banco e recebe as referencias
    final db = await initializeDb();
    int result = 0;

    for (var todo in todos) {
      result = await db.insert(
        'todos',
        todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return result;
  }

  //metodo que lista os todos
  Future<List<Todo>> todos() async {
    final db = await initializeDb();

    //consulta a tabela por todos os afazeres
    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
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

//MEtodo que altera nome do todo
  Future<void> updateTodo(item) async {
    final db = await initializeDb();

    int count = await db.rawUpdate(
        'UPDATE todos SET description = ?, date = ?, time = ?, fk_id_group = ?, WHERE id = ?',
        [item.description, item.date, item.time, item.id, item.fk_id_group]);
    print('$item, $count');
  }

//metodo que altera a coluna checado do item
//e o declara com um todo pronto(feito).
  Future<void> updateChecked(item) async {
    final db = await initializeDb();

    int count = await db.rawUpdate(
        'UPDATE todos SET checked = ? WHERE id = ?', [item.checked, item.id]);
    print('$item, $count');
  }

//Metodo que irá disparar as notificações agendadas
  Future<void> sendNotification() async {
    final db = await initializeDb();

    //Mapa de resultados listados nos todos

    final List<Map<String, dynamic>> maps = await db.query('todos');

    for (var i = 0; i <= maps.length; i++) {
      //Este if converte a hora armezanada como string
      //o mesmo salva com o nome da função junta ao horario
      //o que gera um erro na hora da verificação, sendo necessário esta conversão
      if (TimeOfDay.fromDateTime(DateTime.parse(maps[i]['time'])) ==
          DateTime.now()) {
        print(maps[i]['id']);
        final send = await NotificationService().showNotification(
            maps[i]['id'], maps[i]['name'], maps[i].toString(), 0);
      } else {
        print('erro, verifique toda a linhas de codigo :/');
      }
      return;
    }
  }

//Remove um item da lista
//baseado em sua id
  Future<int> deleteTodo(int? id) async {
    final db = await initializeDb();

    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
