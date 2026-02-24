import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../common/ui_helpers.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.gray150),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            Text('ACCOUNT', style: AppTextStyles.sectionLabel),
            verticalSpaceSmall,
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Email',
              subtitle: viewModel.currentUser?.email ?? '',
            ),
            _SettingsTile(
              icon: Icons.business_outlined,
              title: 'Company',
              subtitle: viewModel.currentUser?.company.isNotEmpty == true
                  ? viewModel.currentUser!.company
                  : 'Not set',
            ),

            verticalSpaceLarge,

            // Notifications section
            Text('NOTIFICATIONS', style: AppTextStyles.sectionLabel),
            verticalSpaceSmall,
            _ToggleTile(
              icon: Icons.chat_bubble_outline,
              title: 'Messages',
              subtitle: 'Get notified about new messages',
              value: viewModel.notifyMessages,
              onChanged: viewModel.toggleNotifyMessages,
            ),
            _ToggleTile(
              icon: Icons.local_offer_outlined,
              title: 'Offers',
              subtitle: 'Get notified about offers on your listings',
              value: viewModel.notifyOffers,
              onChanged: viewModel.toggleNotifyOffers,
            ),
            _ToggleTile(
              icon: Icons.trending_down_outlined,
              title: 'Price Drops',
              subtitle: 'Get notified about price drops on saved items',
              value: viewModel.notifyPriceDrops,
              onChanged: viewModel.toggleNotifyPriceDrops,
            ),
            _ToggleTile(
              icon: Icons.fiber_new_outlined,
              title: 'New Listings',
              subtitle: 'Get notified about new listings in your categories',
              value: viewModel.notifyNewListings,
              onChanged: viewModel.toggleNotifyNewListings,
            ),

            verticalSpaceLarge,

            // Support section
            Text('SUPPORT', style: AppTextStyles.sectionLabel),
            verticalSpaceSmall,
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.gray400, size: 20),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.gray400, size: 20),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.gray400, size: 20),
            ),

            verticalSpaceLarge,

            // Danger zone
            Text('DANGER ZONE', style: AppTextStyles.sectionLabel),
            verticalSpaceSmall,
            _SettingsTile(
              icon: Icons.logout,
              title: 'Sign Out',
              titleColor: AppColors.danger,
              onTap: viewModel.signOut,
            ),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              titleColor: AppColors.danger,
              onTap: viewModel.deleteAccount,
            ),

            verticalSpaceLarge,

            // App version
            Center(
              child: Text(
                '537 Machines v1.0.0',
                style: AppTextStyles.caption,
              ),
            ),
            verticalSpaceMedium,
          ],
        ),
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(BuildContext context) =>
      SettingsViewModel();
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.gray150),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: titleColor ?? AppColors.gray500),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? AppColors.dark,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.titilliumWeb(
                        fontSize: 12,
                        color: AppColors.gray400,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.gray150),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.gray500),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.titilliumWeb(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.titilliumWeb(
                    fontSize: 12,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
