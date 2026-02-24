import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/app_colors.dart';
import 'avatar_widget.dart';
import '../../models/app_user.dart';

class AppDrawer extends StatelessWidget {
  final AppUser? user;
  final VoidCallback onHome;
  final VoidCallback onBrowse;
  final VoidCallback onSell;
  final VoidCallback onMessages;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onNotifications;
  final VoidCallback onSignOut;

  const AppDrawer({
    required this.user,
    required this.onHome,
    required this.onBrowse,
    required this.onSell,
    required this.onMessages,
    required this.onProfile,
    required this.onSettings,
    required this.onNotifications,
    required this.onSignOut,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // User header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.gray150),
                ),
              ),
              child: Row(
                children: [
                  AvatarWidget(
                    initials: user?.initials ?? '?',
                    photoUrl: user?.photoUrl.isNotEmpty == true
                        ? user!.photoUrl
                        : null,
                    size: AvatarSize.sm,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Guest',
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 12,
                            color: AppColors.gray400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    onTap: onHome,
                  ),
                  _DrawerItem(
                    icon: Icons.search,
                    label: 'Browse Machines',
                    onTap: onBrowse,
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline,
                    label: 'Sell a Machine',
                    onTap: onSell,
                  ),
                  _DrawerItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                    onTap: onMessages,
                  ),
                  const Divider(color: AppColors.gray150, height: 16),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'My Profile',
                    onTap: onProfile,
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_none,
                    label: 'Notifications',
                    onTap: onNotifications,
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: onSettings,
                  ),
                ],
              ),
            ),

            // Sign out
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.gray150),
                ),
              ),
              child: _DrawerItem(
                icon: Icons.logout,
                label: 'Sign Out',
                color: AppColors.danger,
                onTap: onSignOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.dark;

    return ListTile(
      leading: Icon(icon, size: 22, color: itemColor),
      title: Text(
        label,
        style: GoogleFonts.titilliumWeb(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: itemColor,
        ),
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
