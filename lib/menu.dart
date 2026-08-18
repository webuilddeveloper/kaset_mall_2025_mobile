// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/component/toast_fail.dart';
import 'package:kasetmall/home.dart';
import 'package:kasetmall/notification/notification.dart';
import 'package:kasetmall/shared/api_provider.dart';
import 'package:kasetmall/user_information.dart';

import 'cart.dart';

class MenuCentralPage extends StatefulWidget {
  const MenuCentralPage({
    super.key,
    this.pageIndex = 0,
    this.commercialOrganization = '0',
  });

  final int pageIndex;
  final String commercialOrganization;

  @override
  State<MenuCentralPage> createState() => _MenuCentralPageState();
}

class _MenuCentralPageState extends State<MenuCentralPage> {
  final storage = const FlutterSecureStorage();
  int _currentPage = 0;
  List<Widget> _widgetOptions = <Widget>[];
  dynamic profile = {'firstName': '', 'lastName': '', 'imageUrl': ''};
  late DateTime currentBackPressTime;
  int notiCount = 3;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.pageIndex.clamp(0, 3);
    _widgetOptions = <Widget>[
      HomeCentralPage(changePage: _changePage),
      CartCentralPage(changePage: _changePage),
      const NotificationCentralPage(),
      UserInformationCentralPage(),
    ];
    _getProfile();
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['screen'] == 'NotificationCentralPage') {
      _onItemTapped(2);
    }
  }

  void _changePage(int index) {
    _onItemTapped(index);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  _getProfile() async {
    final imageUrl = await storage.read(key: 'profileImageUrl');
    final firstName = await storage.read(key: 'profileFirstName');
    final lastName = await storage.read(key: 'profileLastName');

    setState(() {
      profile = {
        'firstName': firstName,
        'lastName': lastName,
        'imageUrl': imageUrl,
      };
    });

    await _insertToken();
  }

  _insertToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    final profileCode = await storage.read(key: 'profileCode10');

    if (token != null) {
      postDio(
        server_we_build + 'notificationV2/m/insertTokenDevice',
        {"token": token, "profileCode": profileCode},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: confirmExit,
      child: Scaffold(
        // extendBody: true,
        backgroundColor: const Color(0xFFF7FAF7),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.white),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: IndexedStack(
                  index: _currentPage,
                  children: _widgetOptions,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE6ECE8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _NavItem(
                          label: 'หน้าแรก',
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          active: _currentPage == 0,
                          onTap: () => _onItemTapped(0),
                        ),
                        _NavItem(
                          label: 'ตะกร้า',
                          icon: Icons.shopping_cart_outlined,
                          activeIcon: Icons.shopping_cart,
                          active: _currentPage == 1,
                          onTap: () => _onItemTapped(1),
                        ),
                        _NavItem(
                          label: 'แจ้งเตือน',
                          icon: Icons.notifications_none_outlined,
                          activeIcon: Icons.notifications,
                          active: _currentPage == 2,
                          onTap: () => _onItemTapped(2),
                          badgeCount: notiCount,
                        ),
                        _NavItem(
                          label: 'โปรไฟล์',
                          icon: Icons.person_outline,
                          activeIcon: Icons.person,
                          active: _currentPage == 3,
                          onTap: () => _onItemTapped(3),
                          networkImage: (profile['imageUrl'] ?? '').toString(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> confirmExit() {
    final now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      toastFail(
        context,
        text: 'กดอีกครั้งเพื่อออก',
        color: Colors.black,
        fontColor: Colors.white,
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.onTap,
    this.badgeCount = 0,
    this.networkImage = '',
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final VoidCallback onTap;
  final int badgeCount;
  final String networkImage;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF13714C) : const Color(0xFF6C756F);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF2F6F3) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  if (networkImage.isNotEmpty)
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(networkImage),
                    )
                  else
                    Icon(active ? activeIcon : icon, color: color, size: 24),
                  if (badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8992B),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Kanit',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontFamily: 'Kanit',
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
