import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../home/home_view.dart';
import '../listings/listings_view.dart';

import '../create_listing/create_listing_view.dart';
import '../messages/messages_view.dart';
import '../profile/profile_view.dart';
import '../../widgets/app_drawer.dart';
import 'main_viewmodel.dart';

class MainView extends StackedView<MainViewModel> {
  const MainView({super.key});

  @override
  Widget builder(
    BuildContext context,
    MainViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      drawer: AppDrawer(
        user: viewModel.currentUser,
        onHome: () {
          Navigator.of(context).pop();
          viewModel.setIndex(0);
        },
        onBrowse: () {
          Navigator.of(context).pop();
          viewModel.setIndex(1);
        },
        onSell: () {
          Navigator.of(context).pop();
          viewModel.setIndex(2);
        },
        onMessages: () {
          Navigator.of(context).pop();
          viewModel.setIndex(3);
        },
        onProfile: () {
          Navigator.of(context).pop();
          viewModel.setIndex(4);
        },
        onSettings: () {
          Navigator.of(context).pop();
          viewModel.navigateToSettings();
        },
        onNotifications: () {
          Navigator.of(context).pop();
          viewModel.navigateToNotifications();
        },
        onSignOut: () {
          Navigator.of(context).pop();
          viewModel.signOut();
        },
      ),
      body: _getViewForIndex(viewModel.currentIndex),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.gray150)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: viewModel.currentIndex == 0,
                  onTap: () => viewModel.setIndex(0),
                ),
                _NavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'Browse',
                  isActive: viewModel.currentIndex == 1,
                  onTap: () => viewModel.setIndex(1),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  label: 'Sell',
                  isActive: viewModel.currentIndex == 2,
                  onTap: () => viewModel.setIndex(2),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Messages',
                  isActive: viewModel.currentIndex == 3,
                  onTap: () => viewModel.setIndex(3),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: viewModel.currentIndex == 4,
                  onTap: () => viewModel.setIndex(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getViewForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeView();
      case 1:
        return const ListingsView();
      case 2:
        return const CreateListingView();
      case 3:
        return const MessagesView();
      case 4:
        return const ProfileView();
      default:
        return const ListingsView();
    }
  }

  @override
  MainViewModel viewModelBuilder(BuildContext context) => MainViewModel();
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryPale : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppColors.primaryDark : AppColors.gray400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.titilliumWeb(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isActive ? AppColors.primaryDark : AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
