import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_bar.dart';
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
  });

  final String title;
  final bool savedOnly;
  final int? orderSubtotal;
  final List<String> orderKeywords;
  final bool selectable;

  @override
  State<PrivilegeAllPage> createState() => _PrivilegeAllPageState();
}

class _PrivilegeAllPageState extends State<PrivilegeAllPage> {
  int _filterIndex = 0;
  Future<List<Map<String, dynamic>>>? _futureCoupons;

  @override
  void initState() {
    super.initState();
    _reloadCoupons();
  }

  void _reloadCoupons() {
    _futureCoupons = CouponStore.getAllCoupons();
  }

  Future<void> _saveCoupon(String id) async {
    await CouponStore.saveCoupon(id);
    setState(_reloadCoupons);
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
    final savedItems =
        widget.savedOnly ? items.where((item) => item['isSaved'] == true).toList() : items;

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

  Widget _buildFilterBar() {
    return const SizedBox.shrink();
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
    final showSelectableMode = widget.selectable && widget.orderSubtotal != null;
    final disabledTint = const Color(0xFFF3F4F6);
    final disabledBorder = const Color(0xFFE5E7EB);
    final disabledText = const Color(0xFF9CA3AF);
    final selectedBackground =
        showSelectableMode && !isEligible ? disabledTint : Colors.white;
    final selectedBorder =
        showSelectableMode && !isEligible ? disabledBorder : AppColors.border;
    final titleColor =
        showSelectableMode && !isEligible ? disabledText : AppColors.textPrimary;
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selectedBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF143D16).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: Container(
              width: 84,
              height: double.infinity,
              color: showSelectableMode && !isEligible
                  ? disabledTint
                  : AppColors.tintGreenSoft,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.local_offer_rounded,
                      color: mainColor,
                      size: 34,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
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
                          fontSize: 9.5,
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
              padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
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
                              fontSize: 13.5,
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
                      fontSize: 16.5,
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
                          backgroundColor:
                              isSaved ? AppColors.tintGreenSoft : AppColors.primary,
                          foregroundColor:
                              isSaved ? AppColors.primary : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSaved ? AppColors.border : AppColors.primary,
                            ),
                          ),
                          ),
                          child: Text(
                          isSaved ? 'เก็บแล้ว ✓' : 'เก็บคูปอง',
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
                            color: isEligible ? AppColors.primary : disabledText,
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
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          final filtered = _applyFilter(items);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

              return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final itemHeight = widget.selectable ? 140.0 : 122.0;
                          return SizedBox(
                            height: itemHeight,
                            child: _buildCouponCard(filtered[index]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
