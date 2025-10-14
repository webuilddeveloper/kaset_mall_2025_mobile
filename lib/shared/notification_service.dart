// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storage = new FlutterSecureStorage();

FirebaseOptions firebaseOption = FirebaseOptions(
  apiKey: Platform.isAndroid
      ? "AIzaSyD-xPSB_Z03rAhvT-_kfMvuo_WaIFpeI-c"
      : "AIzaSyBIDphFjfigO0sDfhmiBX8fx_agkuQ4Wkk",
  appId: Platform.isAndroid
      ? "1:773066081983:android:df4a69b17adb4a5151680a"
      : "1:773066081983:ios:7bf384c74d01a1bc51680a",
  messagingSenderId: "773066081983",
  projectId: "suksapan-mall",
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ตรวจสอบว่า Firebase ถูก initialize หรือยัง
  // await Firebase.initializeApp(options: firebaseOption);

  print('Handling a background message: ${message.messageId}');
  NotificationService.showNotification(message);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // กำหนดการตั้งค่าเริ่มต้นสำหรับ iOS และ Android
  static const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/launcher_icon');

  static const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  static const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id ต้องตรงกับ channel ที่กำหนด
    'High Importance Notifications', // ชื่อ channel
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          print('notification payload: ${response.payload}');
        }
      },
    );

    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> requestPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  static Future<void> subscribeToAllTopic(param) async {
    print('Subscribed to topic "$param"');
    await FirebaseMessaging.instance.unsubscribeFromTopic('suksapan-general');
    await FirebaseMessaging.instance.unsubscribeFromTopic('suksapan-register');
    await FirebaseMessaging.instance.unsubscribeFromTopic('suksapan-item');
    await FirebaseMessaging.instance.unsubscribeFromTopic('suksapan-mall');
    await FirebaseMessaging.instance.subscribeToTopic('suksapan-mall');
    if (param == 'suksapan-register-item') {
      await FirebaseMessaging.instance.subscribeToTopic('suksapan-item');
      await FirebaseMessaging.instance.subscribeToTopic('suksapan-register');
    } else if (param != 'suksapan-mall') {
      await FirebaseMessaging.instance.subscribeToTopic(param);
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  static void setupFirebaseMessaging() {
    FirebaseMessaging.instance.getToken().then((token) async {
      print('FCM Token: $token');

      if (token != null) {
        try {
          var profileCode = (await storage.read(key: 'profileCode10'));
          postDio(server_we_build + 'notificationV2/m/insertTokenDevice',
              {"token": token, "profileCode": profileCode});
        } catch (e) {
          print('Error registering notification token: $e');
        }
      } else {
        print('Failed to get FCM token');
      }
    });

    FirebaseMessaging.instance.subscribeToTopic('suksapan-mall');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened!');
    });
  }
}
