import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'mood_tracker.dart';

class MoodLocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey;

  MoodLocalNotificationService(this.navigatorKey);

  /// Initialize the notification settings
  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotification, // Adjusted according to new API
    );
  }

  Future selectNotification(NotificationResponse response) async {
    // Navigate to the MoodTrackerPage using a named route
    navigatorKey.currentState?.pushNamed('/moodTracker');
  }

  /// Schedule a notification for Android only
  Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime =
        tz.TZDateTime.now(tz.local).add(Duration(seconds: 2));
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'mood_id',
      'mood_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Mood Tracker',
      'Please track your mood',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'Mood Tracker Detail',
    );
  }
}