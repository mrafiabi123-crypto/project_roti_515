import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/page_transitions.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/notification_screen.dart';

class NotificationIconBadge extends StatefulWidget {
  const NotificationIconBadge({super.key});

  @override
  State<NotificationIconBadge> createState() => _NotificationIconBadgeState();
}

class _NotificationIconBadgeState extends State<NotificationIconBadge> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    Future.microtask(() {
      notificationProvider.fetchNotifications(authProvider.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final unreadCount = notificationProvider.unreadCount;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadePageRoute(page: const NotificationScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textDark.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: unreadCount > 0 ? AppColors.primaryOrange : AppColors.textDark,
              size: 22,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
