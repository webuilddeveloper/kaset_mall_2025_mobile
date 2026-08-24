// ignore_for_file: unnecessary_null_comparison, deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasetmall/delivery_address.dart';
import 'package:kasetmall/delete_user.dart';
import 'package:kasetmall/login.dart';
import 'package:kasetmall/policy.dart';
import 'package:kasetmall/privilege_all.dart';
import 'package:kasetmall/shared/app_dialog.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';
import 'package:kasetmall/notification_settings.dart';
import 'package:kasetmall/to_pay.dart';
import 'package:kasetmall/to_rate.dart';
import 'package:kasetmall/to_receive.dart';
import 'package:kasetmall/to_ship.dart';
import 'package:kasetmall/user_profile_form.dart';

class UserInformationCentralPage extends StatefulWidget {
  const UserInformationCentralPage({
    super.key,
    this.changePage,
  });

  final Function? changePage;

  @override
  State<UserInformationCentralPage> createState() =>
      _UserInformationCentralPageState();
}

class _UserInformationCentralPageState
    extends State<UserInformationCentralPage> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  late final VoidCallback _authListener;

  bool _loading = true;
  bool _isLoggedIn = false;
  bool _isShop = false;
  final List<int> _orderCounts = [0, 0, 0, 0];

  String _displayName = '';
  String _phone = '';
  String _profileImageUrl = '';

  final List<_OrderActionData> _orderRows = const [
    _OrderActionData(
      title: 'ที่ต้องชำระ',
      icon: Icons.receipt_long_outlined,
    ),
    _OrderActionData(
      title: 'จัดเตรียมสินค้า',
      icon: Icons.inventory_2_outlined,
    ),
    _OrderActionData(
      title: 'ที่ต้องได้รับ',
      icon: Icons.local_shipping_outlined,
    ),
    _OrderActionData(
      title: 'รอรีวิว',
      icon: Icons.star_outline_rounded,
    ),
  ];

  final List<_MenuRowData> _accountRows = const [
    _MenuRowData(
      title: 'บัญชีผู้ใช้งาน',
      subtitle: 'ชื่อ เบอร์โทร อีเมล และวันเกิด',
      icon: Icons.badge_outlined,
    ),
    _MenuRowData(
      title: 'คูปอง',
      subtitle: 'ดูคูปองที่เก็บแล้ว',
      icon: Icons.confirmation_number_outlined,
    ),
    _MenuRowData(
      title: 'ที่อยู่ของฉัน',
      subtitle: 'จัดการที่อยู่สำหรับรับสินค้า',
      icon: Icons.location_on_outlined,
    ),
  ];

  final List<_MenuRowData> _supportRows = const [
    _MenuRowData(
      title: 'การแจ้งเตือน',
      subtitle: 'จัดการการแจ้งเตือนและข้อความจากระบบ',
      icon: Icons.notifications_none_rounded,
    ),
    _MenuRowData(
      title: 'นโยบาย',
      subtitle: 'อ่านเงื่อนไขการใช้งาน',
      icon: Icons.description_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _authListener = () {
      if (mounted) {
        _loadProfile();
      }
    };
    MockStore.authVersion.addListener(_authListener);
    _loadProfile();
  }

  @override
  void dispose() {
    MockStore.authVersion.removeListener(_authListener);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    await MockStore.loadUserProfile();
    final profile = MockStore.userProfile;
    final isLoggedIn = await MockStore.isLoggedIn();
    final displayName =
        '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim();
    final phone = profile['phone']?.toString() ?? '';
    final profileImageUrl = profile['imageUrl']?.toString() ?? '';
    final isShop = (await storage.read(key: 'isShop') ?? 'false') == 'true';
    final orderCounts = await Future.wait<int>([
      OrderStore.getOrdersByStatus('pendingPayment')
          .then((items) => items.length),
      OrderStore.getOrdersByStatus('preparing').then((items) => items.length),
      OrderStore.getOrdersByStatus('shipping').then((items) => items.length),
      OrderStore.getOrdersByStatus('received').then((items) => items.length),
    ]);

    if (!mounted) return;
    setState(() {
      _isLoggedIn = isLoggedIn;
      _displayName = displayName;
      _phone = phone;
      _profileImageUrl = profileImageUrl;
      _isShop = isShop;
      for (var i = 0; i < _orderCounts.length && i < orderCounts.length; i++) {
        _orderCounts[i] = orderCounts[i];
      }
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await MockStore.clearSession();
    await _loadProfile();
  }

  Future<void> _openAccountPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserProfileForm()),
    );
    await _loadProfile();
  }

  Future<void> _openAddressPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DeliveryAddressCentralPage()),
    );
  }

  Future<void> _openCouponPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrivilegeAllPage(
          title: 'คูปองของฉัน',
          savedOnly: true,
        ),
      ),
    );
  }

  void _openNotificationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
    );
  }

  void _openPolicyPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PolicyCentralPage(
          source: 'profile',
          pendingProfile: MockStore.userProfile,
        ),
      ),
    );
  }

  void _openOrderStatus(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = ToPayCentralPage();
        break;
      case 1:
        page = ToShipCentralPage();
        break;
      case 2:
        page = ToReceiveCentralPage();
        break;
      default:
        page = ToRateCentralPage();
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => page))
        .then((_) => _loadProfile());
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await AppDialog.show(
      context: context,
      title: 'ลบบัญชี',
      description: 'คุณต้องการลบบัญชีนี้ใช่หรือไม่',
      primaryText: 'ยืนยัน',
      secondaryText: 'ย้อนกลับ',
      icon: Icons.delete_outline_rounded,
      primaryColor: AppColors.accent,
    );
    if (confirmed == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DeleteUser()),
      );
    }
  }

  ImageProvider _profileImageProvider(String path) {
    if (path.isEmpty) {
      return const AssetImage('assets/images/kaset/logo_kaset.png');
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/images/kaset/logo_kaset.png');
  }

  Widget _profileAvatar(String path) {
    final hasImage = path.isNotEmpty;

    return Container(
      width: 132,
      height: 132,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? Image(
                image: _profileImageProvider(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      child: Icon(
        _isShop ? Icons.storefront_outlined : Icons.person_rounded,
        size: 58,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHeader() {
    final name = _displayName.isEmpty ? 'ยังไม่ระบุชื่อ' : _displayName;
    final subtitle = _isLoggedIn
        ? (_phone.isNotEmpty ? _phone : 'สมาชิกเกษตร Mall')
        : 'เข้าสู่ระบบเพื่อจัดการคำสั่งซื้อและคูปอง';

    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: _isLoggedIn ? _openAccountPage : _openLoginPage,
                child: _profileAvatar(_profileImageUrl),
              ),
              GestureDetector(
                onTap: _isLoggedIn ? _openAccountPage : _openLoginPage,
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ),
        if (!_isLoggedIn) ...[
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _openLoginPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _openLoginPage,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'สมัคร / เข้าใช้',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _openLoginPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginCentralPage()),
    );
    await _loadProfile();
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Kanit',
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOrderSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.0;

        return SizedBox(
          height: 80,
          // color: Colors.red,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _orderRows.length; i++) ...[
                Expanded(
                  child: _OrderActionButton(
                    title: _orderRows[i].title,
                    icon: _orderRows[i].icon,
                    badge: _orderCounts[i],
                    onTap: () => _openOrderStatus(i),
                  ),
                ),
                if (i != _orderRows.length - 1) const SizedBox(width: gap),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountSection() {
    return _SectionContainer(
      children: [
        _MenuRow(
          data: _accountRows[0],
          onTap: _openAccountPage,
        ),
        Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
        _MenuRow(
          data: _accountRows[1],
          onTap: _openCouponPage,
        ),
        Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
        _MenuRow(
          data: _accountRows[2],
          onTap: _openAddressPage,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _SectionContainer(
      children: [
        _MenuRow(
          data: _supportRows[0],
          onTap: _openNotificationSettings,
        ),
        Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
        _MenuRow(
          data: _supportRows[1],
          onTap: _openPolicyPage,
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: _isLoggedIn ? _logout : _openLoginPage,
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          _isLoggedIn ? 'ออกจากระบบ' : 'เข้าสู่ระบบ',
          style: const TextStyle(
            fontFamily: 'Kanit',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _isLoggedIn ? AppColors.accent : AppColors.primary,
          side: BorderSide(
            color: _isLoggedIn ? AppColors.accent : AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteText() {
    return Center(
      child: TextButton(
        onPressed: _confirmDeleteAccount,
        child: const Text(
          'ลบบัญชี',
          style: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Colors.red,
            decoration: TextDecoration.underline,
            decorationColor: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: 'โปรไฟล์',
        onBack: () {
          if (widget.changePage != null) {
            widget.changePage!(0);
            return;
          }
          Navigator.pop(context);
        },
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              onRefresh: _loadProfile,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  25 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildSectionHeader('คำสั่งซื้อของฉัน'),
                  const SizedBox(height: 8),
                  _buildOrderSection(),
                  const SizedBox(height: 18),
                  _buildSectionHeader('เมนูบัญชี'),
                  const SizedBox(height: 8),
                  _buildAccountSection(),
                  const SizedBox(height: 18),
                  _buildSectionHeader('ช่วยเหลือและการตั้งค่า'),
                  const SizedBox(height: 8),
                  _buildSupportSection(),
                  const SizedBox(height: 18),
                  _buildLogoutButton(),
                  const SizedBox(height: 10),
                  _buildDeleteText(),
                  const SizedBox(height: 65),
                ],
              ),
            ),
    );
  }
}

class _MenuRowData {
  const _MenuRowData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _OrderActionData {
  const _OrderActionData({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.data,
    required this.onTap,
  });

  final _MenuRowData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tintGreenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({
    required this.title,
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.tintGreenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 35,
                    color: AppColors.primary,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 8,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 9.6,
                height: 0.98,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
