import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> init() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: false,
    requestAlertPermission: false,
    requestBadgePermission: false,
    //onDidReceiveLocalNotification: onDidReceiveLocalNotification,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: null,
  );

  tz.initializeTimeZones();

  await FlutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
          android: AndroidNotificationDetails('your channel id',
              'your channel name', 'your channel description')),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime);
}
