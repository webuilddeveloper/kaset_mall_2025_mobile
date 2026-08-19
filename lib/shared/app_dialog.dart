import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_theme.dart';

class AppDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    String primaryText = 'ตกลง',
    String secondaryText = 'ยกเลิก',
    IconData icon = Icons.info_outline_rounded,
    Color? primaryColor,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
  }) {
    final themeColor = primaryColor ?? AppColors.primary;

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AppDialog',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: AppColors.tintGreenSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: themeColor, size: 28),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Kanit',
                          fontSize: 13.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, true);
                            onPrimaryPressed?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            primaryText,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, false);
                            onSecondaryPressed?.call();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            secondaryText,
                            style: const TextStyle(
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
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
      },
    );
  }
}
