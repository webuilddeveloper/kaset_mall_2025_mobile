import 'package:flutter/material.dart';
import 'package:kasetmall/coupon/widgets/daily_checkin_campaign.dart';
import 'package:kasetmall/home.dart';
import 'package:kasetmall/services/local_notification_service.dart';
import 'package:kasetmall/shared/app_bar.dart';
import 'package:kasetmall/shared/app_dialog.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class PrivilegeAllPage extends StatefulWidget {
  const PrivilegeAllPage({
    super.key,
    required this.title,
    this.savedOnly = false,
    this.orderSubtotal,
    this.orderKeywords = const <String>[],
    this.selectable = false,
    this.initialCampaignExpanded = false,
  });

  final String title;
  final bool savedOnly;
  final int? orderSubtotal;
  final List<String> orderKeywords;
  final bool selectable;
  final bool initialCampaignExpanded;

  @override
  State<PrivilegeAllPage> createState() => _PrivilegeAllPageState();
}

class _PrivilegeAllPageState extends State<PrivilegeAllPage> {
  int _filterIndex = 0;
  bool _campaignExpanded = false;
  Future<List<Map<String, dynamic>>>? _futureCoupons;
  Future<Map<String, dynamic>>? _futureCampaign;
  List<Map<String, dynamic>> _cachedCoupons = const <Map<String, dynamic>>[];
  Map<String, dynamic>? _cachedCampaign;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _couponListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _campaignExpanded = widget.initialCampaignExpanded;
    _reloadCoupons();
    _reloadCampaign();
  }

  void _reloadCoupons() {
    final future = CouponStore.getAllCoupons();
    _futureCoupons = future;
    future.then((value) {
      if (!mounted) return;
      setState(() {
        _cachedCoupons = value;
      });
    });
  }

  void _reloadCampaign() {
    final future = DailyCheckInStore.getState();
    _futureCampaign = future;
    future.then((value) {
      if (!mounted) return;
      setState(() {
        _cachedCampaign = value;
      });
    });
  }

  Future<void> _saveCoupon(String id) async {
    await CouponStore.saveCoupon(id);
    setState(_reloadCoupons);
  }

  Future<void> _resetCouponTestData() async {
    print('Resetting...');
    await CouponStore.clearSavedCoupons();
    await CouponStore.clearDynamicCoupons();
    await DailyCheckInStore.resetCampaign();
    await LocalNotificationService.resetDebugState();
    HomeCentralPage.resetDailyCampaignPromptSession();
    await LocalNotificationService.syncDailyCheckInNotification();
    if (!mounted) return;
    _reloadCoupons();
    _reloadCampaign();
    setState(() {});
  }

  bool get _showDailyCheckIn => !widget.savedOnly && !widget.selectable;

  Future<void> _claimDailyCheckIn() async {
    final result = await DailyCheckInStore.claimToday();
    await LocalNotificationService.syncDailyCheckInNotification();
    if (!mounted) return;

    setState(() {
      _reloadCoupons();
      _reloadCampaign();
    });

    if (result['success'] != true) {
      await AppDialog.show(
        context: context,
        title: 'เช็กอินวันนี้แล้ว',
        description: 'วันนี้คุณรับรางวัลไปแล้ว กลับมาเช็กอินใหม่ได้ในวันถัดไป',
        icon: Icons.event_available_rounded,
        primaryText: 'ปิด',
        showSecondary: false,
      );
      return;
    }

    final reward = Map<String, dynamic>.from(
      result['reward'] as Map? ?? const {},
    );
    await AppDialog.show(
      context: context,
      title: 'เช็กอินสำเร็จ!',
      description:
          'คุณได้รับ\n${reward['name'] ?? 'คูปอง'}\n${reward['discount'] ?? ''}',
      icon: Icons.check_circle,
      primaryText: 'ปิด',
      showSecondary: false,
    );
  }

  bool _matchesKeywords(Map<String, dynamic> coupon) {
    if (widget.orderKeywords.isEmpty) return true;

    final couponKeywords = (coupon['eligibleKeywords'] as List<dynamic>?)
            ?.map((e) => e.toString().toLowerCase())
            .toList() ??
        const <String>[];
    if (couponKeywords.isEmpty) return true;

    final orderKeywords =
        widget.orderKeywords.map((e) => e.toString().toLowerCase()).toList();
    for (final keyword in couponKeywords) {
      if (orderKeywords.any((value) => value.contains(keyword))) {
        return true;
      }
    }
    return false;
  }

  bool _isEligible(Map<String, dynamic> coupon) {
    final subtotal = widget.orderSubtotal;
    if (subtotal == null) return true;

    final minimumOrderTotal =
        int.tryParse(coupon['minimumOrderTotal']?.toString() ?? '') ?? 0;
    if (subtotal < minimumOrderTotal) return false;

    return _matchesKeywords(coupon);
  }

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> items) {
    final savedItems = widget.savedOnly
        ? items.where((item) => item['isSaved'] == true).toList()
        : items;

    if (widget.selectable) {
      return savedItems;
    }

    switch (_filterIndex) {
      case 1:
        return savedItems.where((item) => item['isSaved'] != true).toList();
      case 2:
        return savedItems.where((item) => item['isSaved'] == true).toList();
      default:
        return savedItems;
    }
  }

  Widget _buildEmptyState() {
    final title = widget.selectable
        ? 'ยังไม่มีคูปองที่ใช้ได้'
        : 'ยังไม่มีคูปองที่เก็บไว้';
    final subtitle = widget.selectable
        ? 'กลับไปเก็บคูปองที่หน้า Home หรือปรับยอดสั่งซื้อให้ตรงเงื่อนไข'
        : 'กลับไปเก็บคูปองที่หน้า Home ได้ทันที';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.tintGreenSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'กลับหน้าก่อนหน้า',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final isSaved = coupon['isSaved'] == true;
    final isEligible = _isEligible(coupon);
    final showSelectableMode =
        widget.selectable && widget.orderSubtotal != null;
    final disabledTint = const Color(0xFFF3F4F6);
    final disabledBorder = const Color(0xFFE5E7EB);
    final disabledText = const Color(0xFF9CA3AF);
    final selectedBackground =
        showSelectableMode && !isEligible ? disabledTint : Colors.white;
    final selectedBorder =
        showSelectableMode && !isEligible ? disabledBorder : AppColors.border;
    final titleColor = showSelectableMode && !isEligible
        ? disabledText
        : AppColors.textPrimary;
    final mainColor =
        showSelectableMode && !isEligible ? disabledText : AppColors.primary;
    final tagBackground =
        showSelectableMode && !isEligible ? disabledBorder : AppColors.accent;
    final tagTextColor =
        showSelectableMode && !isEligible ? disabledText : Colors.white;
    final statusBackground = showSelectableMode && !isEligible
        ? disabledBorder
        : (isEligible ? AppColors.tintGreenSoft : AppColors.accentTint);
    final statusTextColor = showSelectableMode && !isEligible
        ? disabledText
        : (isEligible ? AppColors.primary : AppColors.accentHover);

    final card = Container(
      decoration: BoxDecoration(
        color: selectedBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: selectedBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D16).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(18)),
            child: Container(
              width: 76,
              height: double.infinity,
              color: showSelectableMode && !isEligible
                  ? disabledTint
                  : AppColors.tintGreenSoft,
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: showSelectableMode && !isEligible
                            ? Colors.white.withValues(alpha: 0.55)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.local_offer_rounded,
                        color: mainColor,
                        size: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tagBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        coupon['tag'] ?? 'คูปอง',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: tagTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          coupon['name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (showSelectableMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isEligible ? 'ใช้ได้' : 'ใช้ไม่ได้',
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: statusTextColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    coupon['discount'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'หมดอายุ ${coupon['expiry'] ?? '-'}',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 11.5,
                      color: showSelectableMode && !isEligible
                          ? disabledText
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (showSelectableMode) ...[
                    const SizedBox(height: 6),
                    Text(
                      'ขั้นต่ำ ${coupon['minimumOrderTotal'] != null ? '฿${coupon['minimumOrderTotal']}' : '-'}',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 11.5,
                        color: showSelectableMode && !isEligible
                            ? disabledText
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (!showSelectableMode)
                    SizedBox(
                      width: 96,
                      height: 30,
                      child: ElevatedButton(
                        onPressed:
                            isSaved ? null : () => _saveCoupon(coupon['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSaved
                              ? AppColors.tintGreenSoft
                              : AppColors.primary,
                          foregroundColor:
                              isSaved ? AppColors.primary : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSaved
                                  ? AppColors.border
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        child: Text(
                          isSaved ? 'เก็บแล้ว' : 'เก็บคูปอง',
                          style: const TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          isEligible
                              ? Icons.chevron_right_rounded
                              : Icons.block_rounded,
                          color: isEligible ? AppColors.primary : disabledText,
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isEligible ? 'กดเพื่อใช้คูปอง' : 'ยังใช้ไม่ได้',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color:
                                isEligible ? AppColors.primary : disabledText,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (showSelectableMode) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEligible ? () => Navigator.pop(context, coupon) : null,
          borderRadius: BorderRadius.circular(16),
          child: card,
        ),
      );
    }

    return card;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KasetAppBar(
        title: widget.title,
        showBackButton: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureCoupons,
        builder: (context, snapshot) {
          final items = snapshot.data ?? _cachedCoupons;
          final filtered = _applyFilter(items);

          if (snapshot.connectionState == ConnectionState.waiting &&
              items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (filtered.isEmpty && !_showDailyCheckIn) {
            return _buildEmptyState();
          }

          final listItemCount = filtered.isEmpty ? 0 : filtered.length;

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            itemCount: (_showDailyCheckIn ? 1 : 0) + 1 + listItemCount,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              var offset = 0;
              if (_showDailyCheckIn) {
                if (index == 0) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: _futureCampaign,
                    builder: (context, campaignSnapshot) {
                      final state = campaignSnapshot.data ?? _cachedCampaign;
                      if (campaignSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          state == null) {
                        return Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.tintGreenSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }
                      if (state == null) {
                        return const SizedBox.shrink();
                      }
                      return DailyCheckInCampaign(
                        campaignState: state,
                        onClaim: _claimDailyCheckIn,
                        expanded: _campaignExpanded,
                        onExpandedChanged: (value) {
                          if (_campaignExpanded == value) return;
                          setState(() {
                            _campaignExpanded = value;
                          });
                        },
                      );
                    },
                  );
                }
                offset = 1;
              }

              if (index == offset) {
                return Container(
                  key: _couponListKey,
                  padding: const EdgeInsets.fromLTRB(2, 4, 2, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.savedOnly
                                  ? 'คูปองของฉัน'
                                  : 'คูปองที่สามารถเก็บได้',
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!widget.savedOnly && !widget.selectable)
                            TextButton(
                              onPressed: _resetCouponTestData,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                foregroundColor: AppColors.textSecondary,
                              ),
                              child: const Text(
                                'Reset ',
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.savedOnly
                            ? 'คูปองที่เก็บไว้พร้อมใช้งาน'
                            : 'เลือกเก็บคูปองที่ต้องการและนำไปใช้กับคำสั่งซื้อถัดไป',
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final couponIndex = index - offset - 1;
              if (couponIndex < 0 || couponIndex >= filtered.length) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.tintGreenSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.local_offer_outlined,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ยังไม่มีคูปองในรายการนี้',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final itemHeight = widget.selectable ? 140.0 : 122.0;
              return SizedBox(
                height: itemHeight,
                child: _buildCouponCard(filtered[couponIndex]),
              );
            },
          );
        },
      ),
    );
  }
}
