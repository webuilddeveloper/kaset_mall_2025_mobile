import 'package:flutter/material.dart';
import 'package:kasetmall/login.dart';
import 'package:kasetmall/shared/app_theme.dart';
import 'package:kasetmall/shared/mock_store.dart';

bool _loginPromptActive = false;

Future<bool> requireLogin(
  BuildContext context, {
  required String title,
  required String description,
}) async {
  final isLoggedIn = await MockStore.isLoggedIn();
  if (isLoggedIn) return true;

  if (_loginPromptActive) return false;
  _loginPromptActive = true;

  if (!context.mounted) return false;
  try {
    final shouldLogin = await showDialog<bool>(
          context: context,
          builder: (sheetContext) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.tintGreenSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
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
                          onPressed: () => Navigator.pop(sheetContext, true),
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
                          onPressed: () => Navigator.pop(sheetContext, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'ไม่ใช่ตอนนี้',
                            style: TextStyle(
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
            );
          },
        ) ??
        false;

    if (shouldLogin && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginCentralPage()),
      );
      return await MockStore.isLoggedIn();
    }

    return false;
  } finally {
    _loginPromptActive = false;
  }
}
