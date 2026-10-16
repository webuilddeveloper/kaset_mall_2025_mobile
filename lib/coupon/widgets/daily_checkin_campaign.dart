import 'package:flutter/material.dart';
import 'package:kasetmall/coupon/widgets/checkin_day_item.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:lottie/lottie.dart';

class DailyCheckInCampaign extends StatefulWidget {
  const DailyCheckInCampaign({
    super.key,
    required this.campaignState,
    required this.onClaim,
    required this.expanded,
    required this.onExpandedChanged,
  });

  final Map<String, dynamic> campaignState;
  final Future<void> Function() onClaim;
  final bool expanded;
  final ValueChanged<bool> onExpandedChanged;

  @override
  State<DailyCheckInCampaign> createState() => _DailyCheckInCampaignState();
}

class _DailyCheckInCampaignState extends State<DailyCheckInCampaign> {
  @override
  Widget build(BuildContext context) {
    final baseDays = List<Map<String, dynamic>>.from(
      widget.campaignState['days'] as List<dynamic>? ??
          const <Map<String, dynamic>>[],
    );
    final days = _buildVisualDays(baseDays);
    final totalDays = days.length;
    final currentDay = widget.campaignState['currentDay'] as int? ?? 1;
    final checkedInToday = widget.campaignState['checkedInToday'] == true;
    final isCycleCompleted = widget.campaignState['isCycleCompleted'] == true;
    final todayReward = Map<String, dynamic>.from(
      widget.campaignState['todayReward'] as Map? ?? const {},
    );
    final claimedDays =
        baseDays.where((day) => day['status']?.toString() == 'claimed').length;
    // Show the available day before claiming and completed progress after claiming.
    final displayDay = checkedInToday
        ? claimedDays.clamp(1, totalDays)
        : currentDay.clamp(1, totalDays);
    final progress = claimedDays / totalDays;
    final buttonText = _buildPrimaryButtonText(
      checkedInToday: checkedInToday,
      currentVisualDay: displayDay,
      todayReward: todayReward,
    );
    final summaryText = _buildSummaryBody(
      checkedInToday: checkedInToday,
      currentVisualDay: displayDay,
      todayReward: todayReward,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: widget.expanded
          ? _buildExpanded(
              context,
              days: days,
              currentDay: displayDay,
              totalDays: totalDays,
              progress: progress,
              checkedInToday: checkedInToday,
              isCycleCompleted: isCycleCompleted,
              buttonText: buttonText,
              summaryText: summaryText,
            )
          : _buildCollapsed(
              currentDay: displayDay,
              totalDays: totalDays,
            ),
    );
  }

  Widget _buildCollapsed({required int currentDay, required int totalDays}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => widget.onExpandedChanged(true),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Row(
            children: [
              const _CampaignIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'เช็กอินรับคูปอง',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'สมาชิกใหม่เช็กอินสะสม $currentDay/$totalDays วัน',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded(
    BuildContext context, {
    required List<Map<String, dynamic>> days,
    required int currentDay,
    required int totalDays,
    required double progress,
    required bool checkedInToday,
    required bool isCycleCompleted,
    required String buttonText,
    required String summaryText,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFA),
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'เช็กอินทุกวัน รับคูปอง',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'สะสมเช็กอิน รับสิทธิ์เพิ่มทุกวัน',
                        style: TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$currentDay / $totalDays',
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = ((constraints.maxWidth - 30) / 4).clamp(
                72.0,
                82.0,
              );
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (int index = 0; index < days.length; index++) ...[
                      SizedBox(
                        width: tileWidth,
                        child: CheckInDayItem(
                          width: tileWidth,
                          day: days[index]['day'] as int? ?? index + 1,
                          label: _dayLabel(
                            day: days[index]['day'] as int? ?? index + 1,
                            status:
                                days[index]['status']?.toString() ?? 'locked',
                          ),
                          rewardText: _rewardLabel(
                            Map<String, dynamic>.from(
                              days[index]['reward'] as Map? ?? const {},
                            ),
                          ),
                          footerText: _footerLabel(
                            reward: Map<String, dynamic>.from(
                              days[index]['reward'] as Map? ?? const {},
                            ),
                            status:
                                days[index]['status']?.toString() ?? 'locked',
                            day: days[index]['day'] as int? ?? index + 1,
                          ),
                          status: days[index]['status']?.toString() ?? 'locked',
                        ),
                      ),
                      if (index != days.length - 1) const SizedBox(width: 10),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            summaryText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(height: 7, color: const Color(0xFFE8EFEB)),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(height: 7, color: const Color(0xFF238043)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed:
                  checkedInToday || isCycleCompleted ? null : widget.onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: const Color(0xFFF0F5F1),
                disabledForegroundColor: const Color(0xFF6E8B75),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: InkWell(
              onTap: () => widget.onExpandedChanged(false),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ย่อรายละเอียด',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 17,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rewardLabel(Map<String, dynamic> reward) {
    if (_isShippingReward(reward)) {
      return 'ส่งฟรี';
    }
    return _displayRewardValue(reward);
  }

  String _dayLabel({required int day, required String status}) {
    if (status == 'today') return 'วันนี้';
    return 'วันที่ $day';
  }

  List<Map<String, dynamic>> _buildVisualDays(List<Map<String, dynamic>> days) {
    final visualDays = List<Map<String, dynamic>>.from(days);
    if (visualDays.length < 8) {
      visualDays.add(
        <String, dynamic>{
          'day': 8,
          'status': 'special',
          'reward': widget.campaignState['dayEightReward'] is Map
              ? Map<String, dynamic>.from(
                  widget.campaignState['dayEightReward'] as Map,
                )
              : <String, dynamic>{},
        },
      );
    }
    return visualDays;
  }

  String _footerLabel({
    required Map<String, dynamic> reward,
    required String status,
    required int day,
  }) {
    if (day == 8) return 'ส่วนลดใหญ่';
    if (status == 'claimed') return 'รับแล้ว';
    if (status == 'today') return 'รับวันนี้';
    return _isShippingReward(reward) ? 'สิทธิ์วันนี้' : 'รอรับ';
  }

  String _buildSummaryBody({
    required bool checkedInToday,
    required int currentVisualDay,
    required Map<String, dynamic> todayReward,
  }) {
    if (checkedInToday) {
      if (currentVisualDay >= 8) {
        return 'รับ${_highlightTodayReward(todayReward)}แล้ว\nขอบคุณที่ร่วมแคมเปญ';
      }
      return 'รับ${_highlightTodayReward(todayReward)}แล้ว\nกลับมาใหม่พรุ่งนี้';
    }
    if (currentVisualDay >= 8) {
      return 'วันสุดท้ายแล้ว\nรับ${_highlightTodayReward(todayReward)}ได้เลย';
    }
    if (_isShippingReward(todayReward)) {
      return 'เช็กอินวันนี้\nรับส่งฟรีทันที';
    }
    return 'เช็กอินวันนี้\nรับ${_highlightTodayReward(todayReward)} ทันที';
  }

  String _buildPrimaryButtonText({
    required bool checkedInToday,
    required int currentVisualDay,
    required Map<String, dynamic> todayReward,
  }) {
    if (checkedInToday) {
      return 'เช็กอินวันนี้เรียบร้อยแล้ว';
    }
    if (currentVisualDay >= 8) {
      return 'รับรางวัลใหญ่ ${_displayRewardValue(todayReward)}';
    }
    if (_isShippingReward(todayReward)) {
      return 'เช็กอินรับส่งฟรี';
    }
    return 'เช็กอินรับ ${_displayRewardValue(todayReward)}';
  }

  String _highlightTodayReward(Map<String, dynamic> reward) {
    if (_isShippingReward(reward)) {
      return 'คูปองส่งฟรี';
    }
    return _rewardText(reward);
  }

  String _rewardText(Map<String, dynamic> reward) {
    final discountType = reward['discountType']?.toString() ?? '';
    final discount = reward['discount']?.toString() ?? '';

    if (discountType == 'shipping' || discount == 'ส่งฟรี') {
      return 'ส่งฟรี';
    }
    if (discount.startsWith('฿')) {
      return 'ส่วนลด $discount';
    }
    if (discount.endsWith('%')) {
      return 'ส่วนลด $discount';
    }
    return 'สิทธิพิเศษ';
  }

  bool _isShippingReward(Map<String, dynamic> reward) {
    final discountType = reward['discountType']?.toString() ?? '';
    final discount = reward['discount']?.toString() ?? '';
    return discountType == 'shipping' || discount == 'ส่งฟรี';
  }

  String _displayRewardValue(Map<String, dynamic> reward) {
    final discount = reward['discount']?.toString() ?? '';
    if (discount.isEmpty) return 'สิทธิ์วันนี้';
    return discount == 'ส่งฟรี' ? 'ส่งฟรี' : discount;
  }
}

class _CampaignIcon extends StatelessWidget {
  const _CampaignIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
        // width: 48,
        // height: 48,
        // decoration: BoxDecoration(
        //   // color: AppColors.primary,
        //   borderRadius: BorderRadius.circular(16),
        // ),
        child: Lottie.asset(
      'assets/lotties/Discount Coupon.json',
      width: 65,
      height: 65,
      fit: BoxFit.contain,
    ));
  }
}
