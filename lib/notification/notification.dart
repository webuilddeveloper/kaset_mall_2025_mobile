// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_dialog.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class NotificationCentralPage extends StatefulWidget {
  const NotificationCentralPage({
    Key? key,
    this.onBack,
  }) : super(key: key);

  final VoidCallback? onBack;

  @override
  State<NotificationCentralPage> createState() =>
      _NotificationCentralPageState();
}

class _NotificationCentralPageState extends State<NotificationCentralPage> {
  late final VoidCallback _notificationListener;
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _notificationListener = () {
      if (mounted) {
        _loadNotifications();
      }
    };
    NotificationStore.notificationVersion.addListener(_notificationListener);
    _loadNotifications();
  }

  @override
  void dispose() {
    NotificationStore.notificationVersion.removeListener(_notificationListener);
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final items = await NotificationStore.getNotifications();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _filteredItems() {
    return _items;
  }

  IconData _iconForType(String type, String? iconName) {
    switch (type) {
      case 'order':
        return Icons.receipt_long_rounded;
      case 'promo':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'order':
        return AppColors.primary;
      case 'promo':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  Future<void> _openDetail(Map<String, dynamic> item) async {
    await NotificationStore.markAsRead(item['id'].toString());
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _colorForType(item['type'].toString())
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _iconForType(
                        item['type']?.toString() ?? '',
                        item['iconName']?.toString(),
                      ),
                      color: _colorForType(item['type'].toString()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']?.toString() ?? '',
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['time']?.toString() ?? '',
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                item['description']?.toString() ?? '',
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 13.5,
                  height: 1.6,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirm = await AppDialog.show(
                          context: context,
                          title: 'ลบการแจ้งเตือน',
                          description: 'คุณต้องการลบการแจ้งเตือนนี้ใช่หรือไม่',
                          primaryText: 'ลบ',
                          secondaryText: 'ยกเลิก',
                          icon: Icons.delete_outline_rounded,
                          primaryColor: AppColors.accent,
                        );
                        if (confirm == true) {
                          await NotificationStore.removeNotification(
                            item['id'].toString(),
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'ลบ',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'ปิด',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    await _loadNotifications();
  }

  Future<void> _markAllRead() async {
    for (final item in _items.where((item) => item['read'] != true)) {
      await NotificationStore.markAsRead(item['id'].toString());
    }
    await _loadNotifications();
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.tintGreenSoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ไม่มีการแจ้งเตือน',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ระบบจะแสดงการแจ้งเตือนเมื่อมีความเคลื่อนไหวใหม่',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final unread = item['read'] != true;
    final type = item['type']?.toString() ?? 'general';
    return Dismissible(
      key: ValueKey(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        final confirmed = await AppDialog.show(
          context: context,
          title: 'ลบการแจ้งเตือน',
          description: 'คุณต้องการลบรายการนี้ใช่หรือไม่',
          primaryText: 'ลบ',
          secondaryText: 'ยกเลิก',
          icon: Icons.delete_outline_rounded,
          primaryColor: AppColors.accent,
        );
        if (confirmed == true) {
          await NotificationStore.removeNotification(item['id'].toString());
          return true;
        }
        return false;
      },
      child: InkWell(
        onTap: () => _openDetail(item),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unread ? Colors.white : const Color(0xFFF5FAF5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unread
                  ? AppColors.primary.withValues(alpha: 0.18)
                  : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _colorForType(type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForType(
                    type,
                    item['iconName']?.toString(),
                  ),
                  color: _colorForType(type),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title']?.toString() ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: unread
                                ? AppColors.accentTint
                                : AppColors.tintGreenSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            unread ? 'ยังไม่อ่าน' : 'อ่านแล้ว',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: unread
                                  ? AppColors.accentHover
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['description']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 12.8,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          item['time']?.toString() ?? '',
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          type == 'order'
                              ? 'คำสั่งซื้อ'
                              : type == 'promo'
                                  ? 'โปรโมชัน'
                                  : 'ทั่วไป',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _colorForType(type),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allCount = _items.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: 'แจ้งเตือน',
        showBackButton: true,
        onBack: widget.onBack,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    children: [
                      Text(
                        'รายการแจ้งเตือน',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _markAllRead,
                        child: const Text(
                          'อ่านทั้งหมด',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _loadNotifications,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                      children: _filteredItems().isEmpty
                          ? [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.55,
                                child: _emptyState(),
                              ),
                            ]
                          : _filteredItems().map(_buildCard).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
