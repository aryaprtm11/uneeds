import 'package:flutter/material.dart';
import 'package:uneeds/models/notification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Note: Untuk menggunakan notifikasi HP, Anda perlu menambahkan dependencies berikut di pubspec.yaml:
// flutter_local_notifications: ^16.3.2
// permission_handler: ^11.1.0

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      await _requestPermissions();
      print('✅ Local notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      // Fallback to console logging if notification setup fails
    }
  }

  Future<void> _createNotificationChannels() async {
    try {
      // Create main notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'uneeds_channel',
        'Uneeds Notifications',
        description: 'Notifications for Uneeds app',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Create scheduled notification channel
      const AndroidNotificationChannel scheduledChannel = AndroidNotificationChannel(
        'uneeds_scheduled',
        'Uneeds Scheduled Notifications',
        description: 'Scheduled notifications for Uneeds app',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(scheduledChannel);

      print('✅ Notification channels created successfully');
    } catch (e) {
      print('❌ Error creating notification channels: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request notification permission untuk Android 13+
      if (await Permission.notification.isDenied) {
        print('📱 Requesting notification permission...');
        final status = await Permission.notification.request();
        print('Notification permission status: $status');
        
        if (status.isDenied) {
          print('❌ Notification permission denied');
        } else if (status.isGranted) {
          print('✅ Notification permission granted');
        } else if (status.isPermanentlyDenied) {
          print('⚠️ Notification permission permanently denied - please enable manually');
        }
      } else if (await Permission.notification.isGranted) {
        print('✅ Notification permission already granted');
      }

      // Request additional permissions if needed
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
      
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  void _onNotificationResponse(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      
      // Handle navigation based on payload
      final parts = payload.split(':');
      if (parts.length == 2) {
        final type = parts[0];
        final id = parts[1];
        
        // You can add navigation logic here
        print('Navigate to $type with ID: $id');
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    try {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'uneeds_channel',
        'Uneeds Notifications',
        channelDescription: 'Notifications for Uneeds app',
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF2B4865),
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      print('📱 HP Notification sent: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
      // Fallback to console notification
      print('📱 [FALLBACK] HP Notification: $title - $body');
    }
  }

  Future<void> showNotificationFromModel(NotificationModel notification) async {
    final priority = _getNotificationPriority(notification.priority);
    
    await showNotification(
      id: notification.id ?? DateTime.now().millisecondsSinceEpoch,
      title: notification.title,
      body: notification.description,
      payload: '${notification.type}:${notification.relatedId ?? 0}',
      priority: priority,
    );
    
    // Also log to console for debugging
    print('📱 HP Notification: [${notification.priority.toUpperCase()}] ${notification.title}');
    print('   ${notification.description}');
  }

  NotificationPriority _getNotificationPriority(String priority) {
    switch (priority) {
      case 'high':
        return NotificationPriority.high;
      case 'medium':
        return NotificationPriority.defaultPriority;
      case 'low':
        return NotificationPriority.low;
      default:
        return NotificationPriority.defaultPriority;
    }
  }

  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.low:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.low:
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print('✅ Cancelled notification with id: $id');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('✅ Cancelled all notifications');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    try {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'uneeds_scheduled',
        'Uneeds Scheduled Notifications',
        channelDescription: 'Scheduled notifications for Uneeds app',
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF2B4865),
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Convert DateTime to TZDateTime
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        platformChannelSpecifics,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('📅 Scheduled notification: $title for ${scheduledDate.toString()}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  // Method untuk schedule daily reminder
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Daily Reminders',
            channelDescription: 'Daily reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF2B4865),
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('📅 Daily reminder scheduled for $hour:$minute');
    } catch (e) {
      print('❌ Error scheduling daily reminder: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Method to show immediate notification for testing
  Future<void> showTestNotification() async {
    await showNotification(
      id: 999,
      title: '🎉 Uneeds Test',
      body: 'Notifikasi HP berhasil diaktifkan!',
      priority: NotificationPriority.high,
    );
  }

  // Method untuk request permission secara manual dari UI
  Future<bool> requestPermissionManually() async {
    try {
      print('🔐 Manual permission request started...');
      
      final status = await Permission.notification.request();
      print('Permission status after manual request: $status');
      
      if (status.isGranted) {
        print('✅ Permission granted successfully');
        // Test notification setelah permission granted
        await showTestNotification();
        return true;
      } else if (status.isDenied) {
        print('❌ Permission denied');
        return false;
      } else if (status.isPermanentlyDenied) {
        print('⚠️ Permission permanently denied - opening app settings');
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (e) {
      print('❌ Error during manual permission request: $e');
      return false;
    }
  }
}

enum NotificationPriority {
  low,
  defaultPriority,
  high,
}

/*
CARA MENGAKTIFKAN NOTIFIKASI HP:

1. Tambahkan dependencies di pubspec.yaml:
   dependencies:
     flutter_local_notifications: ^16.3.2
     permission_handler: ^11.1.0

2. Untuk Android, tambahkan permission di android/app/src/main/AndroidManifest.xml:
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
   <uses-permission android:name="android.permission.VIBRATE" />
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

3. Uncomment implementasi lengkap di atas dan hapus implementasi placeholder

4. Initialize service di main.dart:
   await LocalNotificationService().initialize();
*/ 