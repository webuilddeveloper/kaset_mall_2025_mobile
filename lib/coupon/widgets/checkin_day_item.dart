import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_theme.dart';

class CheckInDayItem extends StatelessWidget {
  const CheckInDayItem({
    super.key,
    required this.day,
    required this.label,
    required this.status,
    required this.rewardText,
    this.footerText,
    this.width = 78,
  });

  final int day;
  final String label;
  final String status;
  final String rewardText;
  final String? footerText;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isClaimed = status == 'claimed';
    final isToday = status == 'today';
    final isSpecial = status == 'special';
    final isSpecialToday = status == 'special_today';

    return Container(
      width: width,
      height: 104,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        color: isSpecial || isSpecialToday
            ? const Color(0xFFFFF5EE)
            : isClaimed
                ? const Color(0xFFF3FBF5)
                : isToday
                    ? const Color(0xFFF8FCF8)
                    : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSpecial || isSpecialToday
              ? const Color(0xFFF0AE87)
              : isClaimed
                  ? const Color(0xFFC8DFC9)
                  : isToday
                      ? const Color(0xFFBFD9C4)
                      : const Color(0xFFD9E2DB),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSpecial || isSpecialToday
                  ? const Color(0xFFE0703C)
                  : isClaimed
                      ? const Color(0xFF74A97C)
                      : isToday
                          ? AppColors.primary
                          : const Color(0xFF88918B),
            ),
          ),
          const Spacer(),
          if (isClaimed)
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 30,
              ),
            )
          else if (isSpecial || isSpecialToday)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  size: 20,
                  color: Color(0xFFE0703C),
                ),
                const SizedBox(height: 4),
                Text(
                  rewardText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE0703C),
                    height: 1.1,
                  ),
                ),
              ],
            )
          else
            Text(
              rewardText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: rewardText.length <= 4 ? 18 : 15,
                fontWeight: FontWeight.w700,
                color:
                    isToday ? AppColors.primaryDark : const Color(0xFF868E88),
                height: 1.1,
              ),
            ),
          const Spacer(),
          if (footerText != null && footerText!.isNotEmpty)
            Text(
              footerText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSpecial || isSpecialToday
                    ? const Color(0xFFE0703C)
                    : isClaimed
                        ? const Color(0xFF74A97C)
                        : isToday
                            ? AppColors.primaryDark
                            : const Color(0xFF88918B),
                height: 1.1,
              ),
            ),
        ],
      ),
    );
  }
}
