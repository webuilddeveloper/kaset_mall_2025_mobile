import 'package:flutter/material.dart';
import 'package:kasetmall/shared/app_theme.dart';

class KasetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KasetAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const <Widget>[],
    this.showBackButton = true,
    this.backgroundColor = Colors.white,
    this.bottomBorder = false,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final bool showBackButton;
  final Color backgroundColor;
  final bool bottomBorder;

  @override
  Size get preferredSize {
    return const Size.fromHeight(52);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      toolbarHeight: 45,
      leadingWidth: showBackButton ? 45 : 0,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _BackButton(onTap: onBack ?? () => Navigator.pop(context)),
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Kanit',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.2,
        ),
      ),
      actions: [
        if (actions.isNotEmpty) ...actions,
        const SizedBox(width: 12),
      ],
      bottom: null,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.tintGreenSoft,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 13,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class KasetAppBarAction extends StatelessWidget {
  const KasetAppBarAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge,
    this.backgroundColor = AppColors.tintGreenSoft,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, size: 21, color: iconColor),
              ),
            ),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badge! > 99 ? '99+' : badge.toString(),
                  style: const TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
