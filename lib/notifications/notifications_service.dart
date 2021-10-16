import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_application_1/service/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  final handler = new DatabaseHandler();

  factory NotificationService() {
    return _notificationService;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> initNotification() async {
    //var initializationSettingsAndroid =
    //    new AndroidInitializationSettings('app_icon');

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await flutterLocalNotificationPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(
      int id, String title, String body, int seconds) async {
    await flutterLocalNotificationPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          'Main channel notifications',
          importance: Importance.max,
          priority: Priority.max,
          icon: 'app_icon',
        ),
        iOS: IOSNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

//Metodo que irá Receber os todos agendadas
  Future<void> ReceiveItensNotification() async {
    final db = await this.handler.initializeDb();
    // var item;

    //Mapa de resultados listados nos todos

    final List<Map<String, dynamic>> maps = await db.query('todos');
    var local_time =
        TimeOfDay.fromDateTime(DateTime.parse(DateTime.now().toString()));
    String formated = local_time.toString().substring(10, 15);
    //var send;
    for (var item in maps) {
      var item_time = item['time'].substring(10, 15);
      //Se a hora for diferente da hora local
      //mantém o app em funcionamento normal
      if (item_time == formated) {
        _sendNotification(item);
        return;
      } else {
        //se algum evento estive marcado na hora local
        //faz o disparo da notificaçã...
        //print('time: ' + item['time'].toString());
        //print('local time: ' + local_time.toString());
        print('Nenhuma tarefa agendada');
      }
    }
  }

  //Metodo que recebe a lista de itens retornados e faz o envio das notificações
  @override
  void _sendNotification(item) async {
    final send = await NotificationService().showNotification(
        item['id'],
        'Alerta agendado.',
        'Você agendou uma terefa ${item['description']}',
        1);
    return send;
  }

//Metodo que cancela o envio de notificações
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationPlugin.cancelAll();
  }
}
