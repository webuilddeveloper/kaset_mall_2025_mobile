import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kasetmall/services/local_notification_service.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

class CheckInCampaignNotification {
  static Future<String?> show({
    required BuildContext context,
    required Map<String, dynamic> campaignState,
  }) {
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CheckInCampaignNotification',
      barrierColor: Colors.black.withValues(alpha: 0.42),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final scale = Tween<double>(begin: 0.94, end: 1).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: _CheckInCampaignNotificationCard(
              initialCampaignState: campaignState,
            ),
          ),
        );
      },
    );
  }
}

class _CheckInCampaignNotificationCard extends StatefulWidget {
  const _CheckInCampaignNotificationCard({
    required this.initialCampaignState,
  });

  final Map<String, dynamic> initialCampaignState;

  @override
  State<_CheckInCampaignNotificationCard> createState() =>
      _CheckInCampaignNotificationCardState();
}

class _CheckInCampaignNotificationCardState
    extends State<_CheckInCampaignNotificationCard>
    with TickerProviderStateMixin {
  late Map<String, dynamic> _campaignState;
  bool _isSubmitting = false;
  bool _justClaimed = false;

  // Big, hard-to-miss confirmation banner shown across the top of the card
  // when a claim succeeds — the small per-cell burst below is a nice touch,
  // but this is the part that guarantees the user actually notices.
  bool _showSuccessBanner = false;
  String? _lastClaimedRewardText;

  // Success burst animation (plays over the "today" cell when a claim
  // succeeds).
  late final AnimationController _burstController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final Animation<double> _ringScale = CurvedAnimation(
    parent: _burstController,
    curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
  ).drive(Tween<double>(begin: 0.4, end: 1.6));
  late final Animation<double> _ringOpacity = CurvedAnimation(
    parent: _burstController,
    curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
  ).drive(Tween<double>(begin: 0.55, end: 0.0));
  late final Animation<double> _checkScale = CurvedAnimation(
    parent: _burstController,
    curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
  );
  late final Animation<double> _checkFade = CurvedAnimation(
    parent: _burstController,
    curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
  ).drive(Tween<double>(begin: 1.0, end: 0.0));

  // Subtle press-scale for the primary button.
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    _campaignState = Map<String, dynamic>.from(widget.initialCampaignState);
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = List<Map<String, dynamic>>.from(
      _campaignState['days'] as List<dynamic>? ??
          const <Map<String, dynamic>>[],
    );
    final claimedDays = List<int>.from(
      _campaignState['claimedDays'] as List<dynamic>? ?? const <int>[],
    );
    final checkedInToday = _campaignState['checkedInToday'] == true;
    final currentDay = ((_campaignState['currentDay'] as int?) ?? 1).clamp(
      1,
      7,
    );
    final todayReward = Map<String, dynamic>.from(
      _campaignState['todayReward'] as Map? ?? const {},
    );
    final currentVisualDay =
        checkedInToday ? claimedDays.length.clamp(1, 7) : currentDay;
    final summaryText = _buildSummaryBody(
      checkedInToday: checkedInToday,
      currentVisualDay: currentVisualDay,
      todayReward: todayReward,
    );
    final buttonText = _buildPrimaryButtonText(
      checkedInToday: checkedInToday,
      currentVisualDay: currentVisualDay,
      todayReward: todayReward,
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 364,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'เช็กอินรับคูปอง',
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'สะสมครบ 8 วัน รับสิทธิ์ทุกวัน',
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF94A094),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: const Color(0xFFF1F5F1),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 8.0;
                          const sideInset = 0.0;
                          final cardSize = (constraints.maxWidth -
                                  (spacing * 3) -
                                  sideInset) /
                              4;

                          Widget buildRow(int startIndex) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: sideInset / 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(4, (offset) {
                                  final index = startIndex + offset;
                                  return SizedBox(
                                    width: cardSize,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: _buildDayCard(
                                        index: index,
                                        currentVisualDay: currentVisualDay,
                                        checkedInToday: checkedInToday,
                                        days: days,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildRow(0),
                              const SizedBox(height: spacing),
                              buildRow(4),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: child,
                          ),
                        ),
                        child: SizedBox(
                          key: ValueKey<bool>(checkedInToday),
                          width: double.infinity,
                          child: Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                children: _buildSummarySpans(
                                  summaryText,
                                  highlightParts: checkedInToday
                                      ? <String>[]
                                      : <String>[
                                          _highlightTodayReward(todayReward),
                                          _remainingText(currentVisualDay),
                                        ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (!checkedInToday) ...[
                        GestureDetector(
                          onTapDown: (_) =>
                              setState(() => _buttonPressed = true),
                          onTapCancel: () =>
                              setState(() => _buttonPressed = false),
                          onTapUp: (_) =>
                              setState(() => _buttonPressed = false),
                          child: AnimatedScale(
                            scale: _buttonPressed ? 0.97 : 1.0,
                            duration: const Duration(milliseconds: 110),
                            curve: Curves.easeOut,
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _handlePrimaryAction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    surfaceTintColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            key: ValueKey<String>(buttonText),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.card_giftcard_rounded,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    buttonText,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontFamily: 'Kanit',
                                                      fontSize: 15.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              checkedInToday ? 'ปิด' : 'ไม่สนใจตอนนี้',
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8A968C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSuccessBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    final text = 'ได้รับ${_lastClaimedRewardText ?? 'คูปอง'}แล้ว';

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: AnimatedSlide(
          offset: _showSuccessBanner ? Offset.zero : const Offset(0, -1.4),
          duration: const Duration(milliseconds: 320),
          curve: _showSuccessBanner ? Curves.easeOutBack : Curves.easeIn,
          child: AnimatedOpacity(
            opacity: _showSuccessBanner ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // Flat solid color — no gradient.
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard({
    required int index,
    required int currentVisualDay,
    required bool checkedInToday,
    required List<Map<String, dynamic>> days,
  }) {
    final dayNumber = index + 1;
    final isBigReward = dayNumber == 8;
    final dayData = dayNumber <= days.length
        ? Map<String, dynamic>.from(days[dayNumber - 1])
        : <String, dynamic>{};
    final reward = Map<String, dynamic>.from(
      dayData['reward'] as Map? ?? const {},
    );
    final isClaimed = dayData['status'] == 'claimed';
    final isToday = !checkedInToday && dayNumber == currentVisualDay;
    final isLocked = !isBigReward && !isClaimed && !isToday;
    final justClaimedThisDay =
        _justClaimed && checkedInToday && dayNumber == currentVisualDay;

    Widget card;

    if (isBigReward) {
      card = _buildStaticCard(
        key: const ValueKey('day8'),
        dayNumber: dayNumber,
        isClaimed: false,
        isToday: false,
      );
    } else if (isToday) {
      card = _buildTodayCard(dayNumber: dayNumber, reward: reward);
    } else if (isClaimed) {
      card = _buildClaimedCard(
        key: ValueKey('claimed-$dayNumber'),
        dayNumber: dayNumber,
        reward: reward,
      );
    } else {
      card = _buildPendingCard(
        key: ValueKey('pending-$dayNumber'),
        dayNumber: dayNumber,
        reward: reward,
        isLocked: isLocked,
      );
    }

    // Animated swap so a cell popping from "today" -> "claimed" (or any
    // status change) scales + fades instead of jump-cutting.
    final animatedCard = AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: card,
    );

    if (!justClaimedThisDay) return animatedCard;

    // The day that was *just* claimed gets a little celebratory burst
    // (expanding ring + checkmark) layered on top for ~900ms.
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        animatedCard,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _burstController,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _ringScale.value,
                    child: Opacity(
                      opacity: _ringOpacity.value,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _checkFade.value,
                    child: Transform.scale(
                      scale: _checkScale.value,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// A perfectly square cell with the day label on top, an icon/value in
  /// the middle, and a short caption on the bottom — all centered as one
  /// balanced group instead of pinned with `Spacer()`.
  Widget _cellFrame({
    Key? key,
    required Color background,
    Color? borderColor,
    required Widget dayLabel,
    required Widget body,
    Widget? footer,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: borderColor == null
            ? null
            : Border.all(
                color: borderColor,
                width: 1.2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 54,
                height: 54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    dayLabel,
                    Expanded(
                      child: Center(child: body),
                    ),
                    if (footer != null) footer,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodayCard({
    required int dayNumber,
    required Map<String, dynamic> reward,
  }) {
    return Stack(
      key: ValueKey('today-$dayNumber'),
      clipBehavior: Clip.none,
      children: [
        _cellFrame(
          background: const Color(0xFF2F9349),
          borderColor: const Color(0xFF25743A),
          dayLabel: _buildDayLabel('วันที่ $dayNumber', Colors.white),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _todayRewardValueLabel(reward),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 8.6,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
          footer: _buildFooterLabel('รับวันนี้', Colors.white),
        ),
        Positioned(
          top: -8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF39A53),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'วันนี้',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 8.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClaimedCard({
    Key? key,
    required int dayNumber,
    required Map<String, dynamic> reward,
  }) {
    return _cellFrame(
      key: key,
      background: const Color(0xFFF1F7F2),
      borderColor: const Color(0xFFD2E5D6),
      dayLabel: _buildDayLabel('วันที่ $dayNumber', const Color(0xFF72997A)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _claimedRewardValueLabel(reward),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 8.1,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C8D67),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
      footer: _buildFooterLabel('รับแล้ว', const Color(0xFF6E9A78)),
    );
  }

  Widget _buildPendingCard({
    Key? key,
    required int dayNumber,
    required Map<String, dynamic> reward,
    required bool isLocked,
  }) {
    return _cellFrame(
      key: key,
      background: const Color(0xFFF8FAF8),
      borderColor: const Color(0xFFE3E8E2),
      dayLabel: _buildDayLabel('วันที่ $dayNumber', const Color(0xFFA6ACA2)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFFCFDFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE3E8E2)),
            ),
            child: Icon(
              isLocked ? Icons.card_giftcard_rounded : Icons.redeem_rounded,
              color: const Color(0xFFA6ACA2),
              size: 10.5,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _pendingRewardValueLabel(reward),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 8.1,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA7B0A8),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
      footer: _buildFooterLabel(
        _pendingLeadLabel(reward),
        const Color(0xFF8E9890),
      ),
    );
  }

  Widget _buildStaticCard({
    Key? key,
    required int dayNumber,
    required bool isClaimed,
    required bool isToday,
  }) {
    final reward = _campaignState['dayEightReward'] is Map
        ? Map<String, dynamic>.from(_campaignState['dayEightReward'] as Map)
        : <String, dynamic>{};
    final valueLabel = _specialRewardValueLabel(reward);
    final headline = valueLabel.isEmpty ? 'รางวัลใหญ่' : valueLabel;

    return _cellFrame(
      key: key,
      background: const Color(0xFFFFF5EE),
      borderColor: const Color(0xFFF0AE87),
      dayLabel: _buildDayLabel('วันที่ $dayNumber', const Color(0xFFE0703C)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFE0703C),
              size: 12,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              headline,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Kanit',
                fontSize: 7.4,
                fontWeight: FontWeight.w800,
                color: Color(0xFFE0703C),
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
      footer: _buildFooterLabel('โบนัสใหญ่', const Color(0xFFE0703C)),
    );
  }

  Widget _buildDayLabel(String text, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Kanit',
        fontSize: 7.4,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.0,
      ),
    );
  }

  Widget _buildFooterLabel(String text, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'Kanit',
        fontSize: 7.0,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.0,
      ),
    );
  }

  Future<void> _handlePrimaryAction() async {
    if (_isSubmitting) return;

    if (_campaignState['checkedInToday'] == true) {
      Navigator.pop(context);
      return;
    }

    final claimedRewardText = _rewardText(
      Map<String, dynamic>.from(
        _campaignState['todayReward'] as Map? ?? const {},
      ),
    );

    setState(() {
      _isSubmitting = true;
    });

    final result = await DailyCheckInStore.claimToday();
    if (!mounted) return;

    if (result['success'] == true) {
      await LocalNotificationService.syncDailyCheckInNotification();
      HapticFeedback.mediumImpact();
      setState(() {
        _campaignState = Map<String, dynamic>.from(
          result['state'] as Map? ?? _campaignState,
        );
        _isSubmitting = false;
        _justClaimed = true;
        _showSuccessBanner = true;
        _lastClaimedRewardText = claimedRewardText;
      });
      _burstController.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        setState(() => _justClaimed = false);
      });
      Future.delayed(const Duration(milliseconds: 1700), () {
        if (!mounted) return;
        setState(() => _showSuccessBanner = false);
      });
      return;
    }

    setState(() {
      _isSubmitting = false;
    });
  }

  List<TextSpan> _buildSummarySpans(
    String text, {
    required List<String> highlightParts,
  }) {
    if (highlightParts.isEmpty) {
      return <TextSpan>[TextSpan(text: text)];
    }

    final spans = <TextSpan>[];
    var remaining = text;

    for (final part in highlightParts.where((e) => e.isNotEmpty)) {
      final index = remaining.indexOf(part);
      if (index < 0) continue;
      if (index > 0) {
        spans.add(TextSpan(text: remaining.substring(0, index)));
      }
      spans.add(
        TextSpan(
          text: part,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      remaining = remaining.substring(index + part.length);
    }

    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining));
    }

    return spans.isEmpty ? <TextSpan>[TextSpan(text: text)] : spans;
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

  String _remainingText(int currentVisualDay) {
    final left = (8 - currentVisualDay).clamp(0, 8);
    return '$left วัน';
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
      return 'ปิด';
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

  String _todayRewardValueLabel(Map<String, dynamic> reward) {
    return _isShippingReward(reward) ? 'ส่งฟรี' : _displayRewardValue(reward);
  }

  String _claimedRewardValueLabel(Map<String, dynamic> reward) {
    return _isShippingReward(reward) ? 'ส่งฟรี' : _displayRewardValue(reward);
  }

  String _pendingLeadLabel(Map<String, dynamic> reward) {
    return 'รอรับ';
  }

  String _pendingRewardValueLabel(Map<String, dynamic> reward) {
    return _isShippingReward(reward) ? 'ส่งฟรี' : _displayRewardValue(reward);
  }

  String _specialRewardValueLabel(Map<String, dynamic> reward) {
    if (reward.isEmpty) return '';
    return _isShippingReward(reward) ? 'ส่งฟรี' : _displayRewardValue(reward);
  }
}
