import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/machine_card.dart';
import '../../widgets/loading_indicator.dart';
import 'profile_viewmodel.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ProfileViewModel viewModel,
    Widget? child,
  ) {
    final user = viewModel.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : CustomScrollView(
              slivers: [
                // Top bar
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.dark,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  title: Text('Profile', style: AppTextStyles.heading3),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: AppColors.gray400),
                      onPressed: viewModel.navigateToSettings,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Profile header
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: [
                        AvatarWidget(
                          initials: user.initials,
                          photoUrl: user.photoUrl.isNotEmpty
                              ? user.photoUrl
                              : null,
                          size: AvatarSize.lg,
                        ),
                        const SizedBox(height: 16),
                        Text(user.displayName,
                            style: AppTextStyles.heading1
                                .copyWith(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(user.email,
                            style: AppTextStyles.caption
                                .copyWith(fontSize: 13)),
                      ],
                    ),
                  ),
                ),

                // Stats row
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          value: viewModel.myListings.length.toString(),
                          label: 'LISTINGS',
                        ),
                        Container(width: 1, height: 36, color: AppColors.gray150),
                        const _StatItem(value: '0', label: 'SALES'),
                        Container(width: 1, height: 36, color: AppColors.gray150),
                        const _StatItem(value: '0', label: 'RATING'),
                      ],
                    ),
                  ),
                ),

                // Edit Profile button
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                    child: CustomButton(
                      title: 'Edit Profile',
                      variant: ButtonVariant.outline,
                      onTap: viewModel.navigateToEditProfile,
                    ),
                  ),
                ),

                // Divider
                SliverToBoxAdapter(
                  child: Container(height: 1, color: AppColors.gray150),
                ),

                // Tabs: My Listings / Saved
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surface,
                    child: Row(
                      children: [
                        _TabButton(
                          label: 'MY LISTINGS',
                          isActive: viewModel.tabIndex == 0,
                          onTap: () => viewModel.setTabIndex(0),
                        ),
                        _TabButton(
                          label: 'SAVED',
                          isActive: viewModel.tabIndex == 1,
                          onTap: () => viewModel.setTabIndex(1),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tab content
                if (viewModel.isBusy)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: LoadingIndicator(),
                    ),
                  )
                else if (viewModel.tabIndex == 0) ...[
                  // My Listings
                  if (viewModel.myListings.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 48, color: AppColors.gray300),
                            verticalSpaceSmall,
                            Text(
                              'No listings yet',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final listing = viewModel.myListings[index];
                            return MachineCard(
                              listing: listing,
                              onTap: () =>
                                  viewModel.openListingDetail(listing.id),
                            );
                          },
                          childCount: viewModel.myListings.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                      ),
                    ),
                ] else ...[
                  // Saved
                  if (viewModel.savedListings.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            const Icon(Icons.favorite_border,
                                size: 48, color: AppColors.gray300),
                            verticalSpaceSmall,
                            Text(
                              'No saved listings yet',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final listing = viewModel.savedListings[index];
                            return MachineCard(
                              listing: listing,
                              onTap: () =>
                                  viewModel.openListingDetail(listing.id),
                            );
                          },
                          childCount: viewModel.savedListings.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                      ),
                    ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) =>
      ProfileViewModel();

  @override
  void onViewModelReady(ProfileViewModel viewModel) => viewModel.init();
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primaryDark : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionLabel.copyWith(
              fontSize: 11,
              color: isActive ? AppColors.primaryDark : AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.sectionLabel.copyWith(fontSize: 10)),
      ],
    );
  }
}
