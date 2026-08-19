import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smoking_app/models/user_model.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationProvider with ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  // Track if init done

  NotificationProvider() {
    _init();
  }

  Future<void> requestPermissionsOnce() async {
    final prefs = await SharedPreferences.getInstance();

    final hasRequested = prefs.getBool('requested_permissions') ?? false;
    if (hasRequested) return;

    // ✅ Ask for notification permissions
    await Permission.notification.request();

    // ✅ Ask for exact alarm permission on Android 13+ only
    if (Platform.isAndroid) {
      final sdkInt = (await _getAndroidSdkVersion()) ?? 0;
      if (sdkInt >= 33 && !(await Permission.scheduleExactAlarm.isGranted)) {
        const intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        );
        await intent.launch();
      }
    }

    // ✅ Set flag to avoid asking again
    await prefs.setBool('requested_permissions', true);
  }

  Future<int?> _getAndroidSdkVersion() async {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    } catch (_) {
      return null;
    }
  }

  Future<void> requestExactAlarmPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();
      if (sdkInt != null && sdkInt >= 33) {
        final status = await Permission.scheduleExactAlarm.status;
        if (!status.isGranted) {
          const intent = AndroidIntent(
            action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
          );
          await intent.launch();
        }
      }
    }
  }

  Future<int?> _getAndroidSdkInt() async {
    try {
      final methodChannel = MethodChannel('device_info');
      final sdkInt = await methodChannel.invokeMethod<int>('getSdkInt');
      return sdkInt;
    } catch (_) {
      return null;
    }
  }

  Future<void> _init() async {
    tzdata.initializeTimeZones();
    _initialized = true;
    await requestPermissionsOnce();

    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    print('Notification permission: ${settings.authorizationStatus}');

    // Prompt user to allow exact alarm if Android 13+

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      showNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tapped logic (e.g., navigate)
  }

  Future<void> showNotification(
      {required String? title, required String? body}) async {
    const androidDetails = AndroidNotificationDetails(
      'smoking_app_channel',
      'Smoking App Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    print('Scheduling: $title at $scheduledTime');

    if (!_initialized) {
      print('Not initialized yet, waiting...');
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 50));
        return !_initialized;
      });
      print('Finished waiting.');
    }

    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _localNotificationsPlugin.zonedSchedule(
        title.hashCode, // unique ID
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Notification should now be scheduled.');
    } on PlatformException catch (e) {
      print('Failed to schedule exact alarm: ${e.message}');
    }
  }

  final List<_NotificationMilestone> milestones = [
    _NotificationMilestone(
      delay: Duration(minutes: 5),
      title: "5 minutes smoke-free!",
      body: "Your pulse and blood pressure are already stabilizing.",
    ),
    _NotificationMilestone(
      delay: Duration(hours: 8),
      title: "8 hours smoke-free!",
      body: "Carbon monoxide levels in your blood are dropping.",
    ),
    _NotificationMilestone(
      delay: Duration(days: 1),
      title: "1 day smoke-free!",
      body: "Your oxygen levels are returning to normal.",
    ),
    _NotificationMilestone(
      delay: Duration(days: 3),
      title: "3 days smoke-free!",
      body: "Breathing becomes easier as lung capacity improves.",
    ),
    _NotificationMilestone(
      delay: Duration(days: 7),
      title: "1 week smoke-free!",
      body: "You've completed a major milestone—stay strong!",
    ),
    _NotificationMilestone(
      delay: Duration(days: 30),
      title: "1 month smoke-free!",
      body: "Your lung function has begun to improve significantly.",
    ),
    _NotificationMilestone(
      delay: Duration(days: 90),
      title: "3 months smoke-free!",
      body: "Your circulation and lung function continue to improve.",
    ),
    _NotificationMilestone(
      delay: Duration(days: 365),
      title: "1 year smoke-free!",
      body: "Your risk of coronary heart disease is cut in half.",
    ),
  ];

  // 🔔 Daily Tips Data
  final List<String> dailyTips = [
    "Stay strong! Each craving only lasts a few minutes.",
    "Think about all the money you're saving!",
    "Stay hydrated—it helps fight cravings.",
    "Replace smoking time with a new habit.",
    "Avoid triggers—change your routine if needed.",
    "Reward yourself for making it another day!"
  ];

  Future<void> scheduleDailyTipNotifications(UserModel user) async {
    final quitDateTimestamp = user.quitDate;
    if (quitDateTimestamp == null) return;

    final quitDate = quitDateTimestamp.toDate();
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < dailyTips.length; i++) {
      final scheduledDate = DateTime(
        quitDate.year,
        quitDate.month,
        quitDate.day,
      ).add(Duration(days: i, hours: 9)); // Tip at 9:00 AM each day

      if (scheduledDate.isAfter(now)) {
        final key = 'scheduled_daily_tip_$i';
        if (!(prefs.getBool(key) ?? false)) {
          await scheduleNotification(
            title: "Daily Tip",
            body: dailyTips[i],
            scheduledTime: scheduledDate,
          );
          await prefs.setBool(key, true);
        }
      }
    }
  }

  void scheduleUserNotifications(UserModel user) {
    final quitDateTimestamp = user.quitDate;
    if (quitDateTimestamp == null) return;

    final quitDate = quitDateTimestamp.toDate();
    final now = DateTime.now();

    for (final milestone in milestones) {
      final scheduledTime = quitDate.add(milestone.delay);

      if (scheduledTime.isAfter(now)) {
        scheduleNotification(
          title: milestone.title,
          body: milestone.body,
          scheduledTime: scheduledTime,
        );
      }
    }
  }

  void checkAttributeNotifications(UserModel user) async {
    int minutesSinceQuit = 0;
    final prefs = await SharedPreferences.getInstance();
    final quitDate1 = user.quitDate.toDate();
    final now = DateTime.now();
    minutesSinceQuit = now.difference(quitDate1).inMinutes;
    final moneySaved =
        ((user.cigarettesPerDay / user.cigarettesPerPack * 1440) *
            user.costPerPack *
            minutesSinceQuit);
    if (moneySaved >= 50 && !(prefs.getBool('notified_money_50') ?? false)) {
      showNotification(
        title: "Money saved milestone!",
        body: "You saved \$50 by not smoking. Keep it up!",
      );
      await prefs.setBool('notified_money_50', true);
    }
    if (moneySaved >= 100 && !(prefs.getBool('notified_money_100') ?? false)) {
      showNotification(
        title: "Money saved milestone!",
        body: "You saved \$100 by not smoking. Keep it up!",
      );
      await prefs.setBool('notified_money_100', true);
    }

    // Add other attribute checks similarly...
  }

  Future<void> resetScheduledNotifications(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Cancel all scheduled notifications
    await _localNotificationsPlugin.cancelAll();

    // 2. Clear scheduled daily tip flags
    for (int i = 0; i < dailyTips.length; i++) {
      await prefs.remove('scheduled_daily_tip_$i');
      //await prefs.remove('scheduled_daily_tip_$i');
    }

    // 3. Clear any other notification flags if needed (e.g., money milestones)
    //await prefs.remove('notified_money_50');
    //await prefs.remove('notified_money_100');
    // Add other flags here if you have more...

    // 4. Reschedule milestone and daily tip notifications
    scheduleUserNotifications(user);
    await scheduleDailyTipNotifications(user);

    // Optionally: Notify UI if needed
    notifyListeners();
  }
}

class _NotificationMilestone {
  final Duration delay;
  final String title;
  final String body;

  const _NotificationMilestone({
    required this.delay,
    required this.title,
    required this.body,
  });
}
