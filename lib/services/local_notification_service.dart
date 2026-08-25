import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void onLocalNotificationTapBackground(NotificationResponse response) {
  if (response.payload == LocalNotificationService.dailyCheckInPayload) {
    LocalNotificationService.triggerDailyCheckInActionFromNotification();
  }
}

class LocalNotificationService {
  LocalNotificationService._();

  static const int instantCampaignNotificationId = 8000;
  static const int dailyCheckInNotificationId = 8001;
  static const String dailyCheckInPayload = 'daily_check_in';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final ValueNotifier<int> dailyCheckInActionVersion =
      ValueNotifier<int>(0);

  static bool _initialized = false;
  static bool _hasPendingDailyCheckInAction = false;
  static bool _hasShownImmediateReminderThisSession = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onLocalNotificationTapBackground,
    );

    const channel = AndroidNotificationChannel(
      'daily_check_in_channel',
      'Daily Check-in Notifications',
      description: 'Reminder notifications for the daily check-in campaign',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchedPayload = launchDetails?.notificationResponse?.payload;
    if (launchedPayload == dailyCheckInPayload) {
      _markPendingDailyCheckInAction();
    }

    _initialized = true;
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> syncDailyCheckInNotification() async {
    await initialize();

    final state = await DailyCheckInStore.getState();
    final checkedInToday = state['checkedInToday'] == true;
    final isCycleCompleted = state['isCycleCompleted'] == true;
    final todayReward =
        Map<String, dynamic>.from(state['todayReward'] as Map? ?? const {});

    if (checkedInToday || isCycleCompleted || todayReward.isEmpty) {
      await cancelDailyCheckInNotification();
      debugPrint(
        '[DailyCheckInNotification] skipped: checkedInToday=$checkedInToday isCycleCompleted=$isCycleCompleted rewardEmpty=${todayReward.isEmpty}',
      );
      return;
    }

    final scheduledDate = _nextScheduleDateTime();
    final content = _buildNotificationContent(
      reward: todayReward,
      currentDay: (state['currentDay'] as int?) ?? 1,
    );

    await cancelDailyCheckInNotification();

    await _plugin.zonedSchedule(
      dailyCheckInNotificationId,
      content.title,
      content.body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_check_in_channel',
          'Daily Check-in Notifications',
          channelDescription:
              'Reminder notifications for the daily check-in campaign',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: dailyCheckInPayload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    debugPrint(
      '[DailyCheckInNotification] scheduled for ${scheduledDate.toString()} title="${content.title}"',
    );
  }

  static Future<void> showImmediateCampaignReminderOnce() async {
    await initialize();

    if (_hasShownImmediateReminderThisSession) {
      return;
    }

    final state = await DailyCheckInStore.getState();
    final checkedInToday = state['checkedInToday'] == true;
    final isCycleCompleted = state['isCycleCompleted'] == true;
    final todayReward =
        Map<String, dynamic>.from(state['todayReward'] as Map? ?? const {});

    if (checkedInToday || isCycleCompleted || todayReward.isEmpty) {
      debugPrint(
        '[DailyCheckInNotification] immediate skipped: checkedInToday=$checkedInToday isCycleCompleted=$isCycleCompleted rewardEmpty=${todayReward.isEmpty}',
      );
      return;
    }

    final content = _buildNotificationContent(
      reward: todayReward,
      currentDay: (state['currentDay'] as int?) ?? 1,
    );

    await _plugin.show(
      instantCampaignNotificationId,
      '🎁 วันนี้มีแคมเปญเช็กอินรับคูปอง',
      content.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_check_in_channel',
          'Daily Check-in Notifications',
          channelDescription:
              'Reminder notifications for the daily check-in campaign',
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: dailyCheckInPayload,
    );

    _hasShownImmediateReminderThisSession = true;
    debugPrint('[DailyCheckInNotification] immediate reminder shown');
  }

  static Future<void> cancelDailyCheckInNotification() async {
    await _plugin.cancel(dailyCheckInNotificationId);
    debugPrint('[DailyCheckInNotification] canceled');
  }

  static Future<void> resetDebugState() async {
    _hasPendingDailyCheckInAction = false;
    _hasShownImmediateReminderThisSession = false;
    await _plugin.cancel(instantCampaignNotificationId);
    await cancelDailyCheckInNotification();
  }

  static bool consumePendingDailyCheckInAction() {
    final shouldOpen = _hasPendingDailyCheckInAction;
    _hasPendingDailyCheckInAction = false;
    return shouldOpen;
  }

  static Future<void> triggerDailyCheckInActionFromNotification() async {
    _markPendingDailyCheckInAction();
  }

  static Future<List<PendingNotificationRequest>> pendingNotifications() {
    return _plugin.pendingNotificationRequests();
  }

  static tz.TZDateTime _nextScheduleDateTime() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      12,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (response.payload == dailyCheckInPayload) {
      _markPendingDailyCheckInAction();
    }
  }

  static void _markPendingDailyCheckInAction() {
    _hasPendingDailyCheckInAction = true;
    dailyCheckInActionVersion.value++;
  }

  static _NotificationContent _buildNotificationContent({
    required Map<String, dynamic> reward,
    required int currentDay,
  }) {
    final rewardValue = reward['discount']?.toString() ?? '';
    final isShipping = _isShippingReward(reward);

    if (isShipping) {
      return const _NotificationContent(
        title: '🚚 วันนี้รับส่งฟรี!',
        body: 'เข้าแอปมาเช็กอิน รับคูปองส่งฟรีกันเลย',
      );
    }

    if (currentDay >= 8) {
      return _NotificationContent(
        title: '🎉 ถึงรางวัลใหญ่แล้ว!',
        body:
            'เช็กอินวันที่ 8 รับ${_notificationRewardText(rewardValue)} วันนี้',
      );
    }

    return _NotificationContent(
      title: '🎁 รางวัลวันนี้รออยู่!',
      body:
          'เช็กอินวันที่ $currentDay รับ${_notificationRewardText(rewardValue)} ได้เลย',
    );
  }

  static bool _isShippingReward(Map<String, dynamic> reward) {
    final discountType = reward['discountType']?.toString() ?? '';
    final discount = reward['discount']?.toString() ?? '';
    return discountType == 'shipping' || discount == 'ส่งฟรี';
  }

  static String _notificationRewardText(String discount) {
    if (discount == 'ส่งฟรี') return 'ส่งฟรี';
    if (discount.startsWith('฿')) {
      return 'ส่วนลด ${discount.replaceFirst('฿', '')} บาท';
    }
    return discount;
  }
}

class _NotificationContent {
  const _NotificationContent({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
