import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomNotification {
  static final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();
  static bool isInit = false;

  static void init() {
    if (isInit) return;
    isInit = true;
    InitializationSettings initializeSettings = InitializationSettings(android: const AndroidInitializationSettings("@mipmap/ic_launcher"));
    notification.initialize(initializeSettings);
  }

  static void send(String title, String content) {
    init();
    NotificationDetails notificationDetails =
        NotificationDetails(android: const AndroidNotificationDetails("nano71.com", "上课通知", importance: Importance.max, priority: Priority.high));
    notification.show(DateTime.now().millisecondsSinceEpoch >> 10, title, content, notificationDetails);
  }
}
