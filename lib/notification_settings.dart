import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _loading = true;
  bool _master = true;
  bool _promo = true;
  bool _order = true;
  bool _coupon = true;
  bool _news = false;
  bool _sound = true;
  bool _vibration = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _master = prefs.getBool('notify_master') ?? true;
      _promo = prefs.getBool('notify_promo') ?? true;
      _order = prefs.getBool('notify_order') ?? true;
      _coupon = prefs.getBool('notify_coupon') ?? true;
      _news = prefs.getBool('notify_news') ?? false;
      _sound = prefs.getBool('notify_sound') ?? true;
      _vibration = prefs.getBool('notify_vibration') ?? true;
      _loading = false;
    });
  }

  Future<void> _save({
    bool? master,
    bool? promo,
    bool? order,
    bool? coupon,
    bool? news,
    bool? sound,
    bool? vibration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (master != null) await prefs.setBool('notify_master', master);
    if (promo != null) await prefs.setBool('notify_promo', promo);
    if (order != null) await prefs.setBool('notify_order', order);
    if (coupon != null) await prefs.setBool('notify_coupon', coupon);
    if (news != null) await prefs.setBool('notify_news', news);
    if (sound != null) await prefs.setBool('notify_sound', sound);
    if (vibration != null) await prefs.setBool('notify_vibration', vibration);
  }

  Future<void> _setMaster(bool value) async {
    setState(() {
      _master = value;
      if (!value) {
        _promo = false;
        _order = false;
        _coupon = false;
        _news = false;
      }
    });
    await _save(
      master: value,
      promo: _promo,
      order: _order,
      coupon: _coupon,
      news: _news,
    );
  }

  Future<void> _setSwitch(String key, bool value) async {
    setState(() {
      switch (key) {
        case 'promo':
          _promo = value;
          break;
        case 'order':
          _order = value;
          break;
        case 'coupon':
          _coupon = value;
          break;
        case 'news':
          _news = value;
          break;
        case 'sound':
          _sound = value;
          break;
        case 'vibration':
          _vibration = value;
          break;
      }
      if (value) {
        _master = true;
      }
    });

    await _save(
      master: _master,
      promo: _promo,
      order: _order,
      coupon: _coupon,
      news: _news,
      sound: _sound,
      vibration: _vibration,
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.tintGreenSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KasetAppBar(
        title: 'การแจ้งเตือน',
        showBackButton: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FBF7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'จัดการการแจ้งเตือนที่คุณต้องการรับจากแอป',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _switchTile(
                  title: 'เปิดการแจ้งเตือนทั้งหมด',
                  subtitle: 'ควบคุมการแจ้งเตือนทั้งแอป',
                  value: _master,
                  onChanged: _setMaster,
                  icon: Icons.notifications_active_outlined,
                ),
                const SizedBox(height: 12),
                _switchTile(
                  title: 'โปรโมชัน',
                  subtitle: 'คูปอง ส่วนลด และข้อเสนอพิเศษ',
                  value: _promo,
                  onChanged: (value) => _setSwitch('promo', value),
                  icon: Icons.local_offer_outlined,
                ),
                const SizedBox(height: 12),
                _switchTile(
                  title: 'คำสั่งซื้อ',
                  subtitle: 'สถานะการสั่งซื้อและการจัดส่ง',
                  value: _order,
                  onChanged: (value) => _setSwitch('order', value),
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 12),
                _switchTile(
                  title: 'คูปอง',
                  subtitle: 'แจ้งเตือนคูปองที่เก็บไว้และคูปองใหม่',
                  value: _coupon,
                  onChanged: (value) => _setSwitch('coupon', value),
                  icon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: 12),
                _switchTile(
                  title: 'ข่าวสาร',
                  subtitle: 'ข่าวและประกาศสำคัญ',
                  value: _news,
                  onChanged: (value) => _setSwitch('news', value),
                  icon: Icons.article_outlined,
                ),
                const SizedBox(height: 12),
                _switchTile(
                  title: 'เสียงแจ้งเตือน',
                  subtitle: 'เปิดหรือปิดเสียงสำหรับแจ้งเตือน',
                  value: _sound,
                  onChanged: (value) => _setSwitch('sound', value),
                  icon: Icons.volume_up_outlined,
                ),
                const SizedBox(height: 12),
                _switchTile(
                  title: 'สั่น',
                  subtitle: 'ให้เครื่องสั่นเมื่อมีการแจ้งเตือน',
                  value: _vibration,
                  onChanged: (value) => _setSwitch('vibration', value),
                  icon: Icons.vibration_outlined,
                ),
              ],
            ),
    );
  }
}
