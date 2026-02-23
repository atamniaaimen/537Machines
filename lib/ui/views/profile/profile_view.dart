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
                      onPressed: viewModel.signOut,
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

                // My Listings header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text('MY LISTINGS', style: AppTextStyles.sectionLabel),
                  ),
                ),

                // Listings grid or empty state
                if (viewModel.isBusy)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: LoadingIndicator(),
                    ),
                  )
                else if (viewModel.myListings.isEmpty)
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
