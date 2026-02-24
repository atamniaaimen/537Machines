import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../widgets/loading_indicator.dart';
import '../../../models/app_notification.dart';
import '../../../core/utils/date_formatter.dart';
import 'notifications_viewmodel.dart';

class NotificationsView extends StackedView<NotificationsViewModel> {
  const NotificationsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    NotificationsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.gray150),
        ),
        actions: [
          if (viewModel.unreadCount > 0)
            TextButton(
              onPressed: viewModel.markAllRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
        ],
      ),
      body: viewModel.isBusy
          ? const LoadingIndicator(message: 'Loading notifications...')
          : viewModel.notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_none,
                          size: 48, color: AppColors.gray300),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.gray400),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.notifications.length,
                  itemBuilder: (context, index) {
                    final notif = viewModel.notifications[index];
                    return _NotificationTile(
                      notification: notif,
                      onTap: () {
                        if (!notif.isRead) {
                          viewModel.markAsRead(notif.id);
                        }
                      },
                    );
                  },
                ),
    );
  }

  @override
  NotificationsViewModel viewModelBuilder(BuildContext context) =>
      NotificationsViewModel();

  @override
  void onViewModelReady(NotificationsViewModel viewModel) => viewModel.init();
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : AppColors.primaryPale,
          border: Border(
            bottom: BorderSide(color: AppColors.gray150),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 15,
                      fontWeight:
                          notification.isRead ? FontWeight.w400 : FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 13,
                      color: AppColors.gray500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormatter.timeAgo(notification.createdAt),
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 11,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.message:
        icon = Icons.chat_bubble_outline;
        color = const Color(0xFF2980B9);
        break;
      case NotificationType.offer:
        icon = Icons.local_offer_outlined;
        color = AppColors.primaryDark;
        break;
      case NotificationType.priceAlert:
        icon = Icons.trending_down;
        color = const Color(0xFFE67E22);
        break;
      case NotificationType.system:
        icon = Icons.info_outline;
        color = AppColors.gray500;
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}
