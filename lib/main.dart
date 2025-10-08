import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart' as SchedulerBinding;
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_mart_v3/dark_mode.dart';
import 'package:mobile_mart_v3/version.dart';
import 'package:provider/provider.dart';
// import 'package:wereward/shared/notification_service.dart';
import 'package:mobile_mart_v3/shared/notification_service.dart';

import 'shared/api_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Intl.defaultLocale = 'th';
  // initializeDateFormatting();
  await Firebase.initializeApp(options: firebaseOption);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  NotificationService.initialize();
  NotificationService.requestPermission();
  NotificationService.subscribeToAllTopic('suksapan-mall');

  //16557962-88 SUKSAPAN Online
  //16564548-34 SUKSAPAN Online
  await LineSDK.instance.setup("1660657781").then((_) {
    print("✅ LineSDK Initialized Successfully");
  }).catchError((e) {
    print("❌ Error Initializing LineSDK: $e");
  });

  // these 2 lines
  // WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp();

  // NotificationService.instance.start();

  // await Firebase.initializeApp();

  HttpOverrides.global = MyHttpOverrides();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('th')],
      path: 'assets/lang',
      fallbackLocale: Locale('th'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // This widget is the root of your application.
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  late StreamSubscription _sub;
  final navigatorKey = GlobalKey<NavigatorState>();
  late Future<dynamic> _futureModel;

  final stopwatch = Stopwatch();
  Duration elapsed = Duration();
  final storage = new FlutterSecureStorage();
  String _profileCode = '';
  String _username = '';
  String platform = '';

  @override
  void initState() {
    super.initState();
    stopwatch.start();
    _getUser();
    _checkPlatform();
    _initUriLinks();

    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.SchedulerBinding.instance.addPostFrameCallback((_) {
      print('addPostFrameCallback');
    });

    _setupFirebaseMessaging();

    FirebaseMessaging.instance.getToken().then((token) {
      // print("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('Message received in foreground: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('Notification opened!');
    });
  }

  void _setupFirebaseMessaging() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    if (Platform.isIOS) {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 Permission granted: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print("✅ APNs Token: $apnsToken");

        String? fcmToken = await FirebaseMessaging.instance.getToken();
        print("✅ FCM Token: $fcmToken");
      } else {
        print("❌ Notification permission not granted");
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened!');
    });
  }

  void _initUriLinks() async {
    _sub = AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _navigateToPage(uri);
      }
    }, onError: (err) {
      // print('Failed to receive deep link: $err');
    });
  }

  void _navigateToPage(Uri uri) async {
    if (uri.host == 'product' && uri.queryParameters['code'] != null) {
      String productCode = uri.queryParameters['code']!;

      dynamic model = await getData('${server}products/$productCode');

      if (navigatorKey.currentState != null) {
        //// print('Navigating to ProductFormCentralPage with code: $productCode');
        // navigatorKey.currentState?.push(
        //   MaterialPageRoute(
        //     builder: (context) => ProductFormCentralPage(model: model),
        //   ),
        // );
      } else {
        // print('Navigator is not available.');
      }
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // ต้องตรงกับ channel_id ที่ใช้ส่งจาก Firebase
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // await flutterLocalNotificationsPlugin.show(
    //   0, // ID ของการแจ้งเตือน
    //   message.notification?.title,
    //   message.notification?.body,
    //   platformChannelSpecifics,
    // );
  }

  _getUser() async {
    var code = await storage.read(key: 'profileCode10') ?? '';
    var user = await storage.read(key: 'profileUserName') ?? 'ไม่ระบุตัวตน';

    setState(() {
      _profileCode = code;
      _username = user;
    });
  }

  _checkPlatform() {
    setState(() {
      if (Platform.isAndroid) {
        platform = 'android';
      }
      if (Platform.isIOS) {
        platform = 'ios';
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // print('state = $state');
    if (state == AppLifecycleState.inactive) {
      _stop();
    }
    if (state == AppLifecycleState.resumed) {
      _start();
    }
    // if (state == AppLifecycleState.detached) {
    //   _stop();
    // }
  }

  _stop() {
    stopwatch.stop();
    setState(() {
      elapsed = stopwatch.elapsed;
    });
    stopwatch.reset();

    postDio(server_we_build + 'log/logUserMobile/create', {
      'username': _username,
      'platform': platform,
      'profileCode': _profileCode,
      'second': elapsed.inSeconds,
    });
  }

  _start() {
    setState(() {
      elapsed = Duration();
    });
    stopwatch.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // set bacground color notificationbar.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // portrait only.
    _portraitModeOnly();
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (BuildContext context, value, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              primaryColor: Color(0xFFEC008C),
              colorScheme: ColorScheme.light(
                primary: Color(0xFFEC008C),
                secondary: Color(0xFFFC6767), // ใช้แทน accentColor
                surfaceBright: Color(0xFFf7f7f7), // ใช้แทน backgroundColor
              ),
              scaffoldBackgroundColor:
                  Color(0xFFf7f7f7), // ใช้แทน backgroundColor
              fontFamily: 'Kanit',
            ),
            title: appName,
            home: VersionPage(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child ?? Container(),
              );
            },
          );
        },
      ),
    );
  }
}

void _portraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
