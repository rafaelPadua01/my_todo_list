import 'package:flutter/material.dart';
import 'package:flutter_application_1/notifications/notifications_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  NotificationService().cancelAllNotifications();
                },
                child: Container(
                  height: 400,
                  width: 200,
                  color: Colors.red,
                  child: Center(
                    child: Text('Cancel all Notifications'),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  NotificationService()
                      .showNotification(1, 'title', 'body', 10);
                },
                child: Container(
                  height: 400,
                  width: 200,
                  color: Colors.red,
                  child: Center(
                    child: Text('show notification'),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
