import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../widgets/machine_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/avatar_widget.dart';
import 'listings_viewmodel.dart';

class ListingsView extends StackedView<ListingsViewModel> {
  const ListingsView({super.key});

  @override
  Widget builder(
    BuildContext context,
    ListingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LogoWidget(size: LogoSize.sm),
                  Row(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          size: 22, color: AppColors.gray500),
                      const SizedBox(width: 12),
                      AvatarWidget(
                        initials: viewModel.userInitials,
                        photoUrl: viewModel.userPhotoUrl,
                        size: AvatarSize.sm,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: viewModel.refresh,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading
                      Text(
                        'Browse Machines',
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${viewModel.listings.length} machines available',
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.gray400,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search bar
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onSubmitted: viewModel.search,
                              style: GoogleFonts.titilliumWeb(
                                fontSize: 15,
                                color: AppColors.dark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search machines, brands, models...',
                                hintStyle: GoogleFonts.titilliumWeb(
                                  fontSize: 15,
                                  color: AppColors.gray300,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.gray200, width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.gray200, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 1.5),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: viewModel.showFilterSheet,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: viewModel.hasActiveFilters
                                      ? AppColors.primary
                                      : AppColors.gray200,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.tune,
                                size: 20,
                                color: viewModel.hasActiveFilters
                                    ? AppColors.primaryDark
                                    : AppColors.gray500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Category chips
                      SizedBox(
                        height: 32,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.categoryTags.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final tag = viewModel.categoryTags[index];
                            final isSelected =
                                tag == viewModel.selectedCategoryTag;
                            return GestureDetector(
                              onTap: () => viewModel.selectCategoryTag(tag),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryPale
                                      : AppColors.gray100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.titilliumWeb(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: isSelected
                                        ? AppColors.primaryDark
                                        : AppColors.gray500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Content
                      if (viewModel.isBusy)
                        const Padding(
                          padding: EdgeInsets.only(top: 60),
                          child:
                              LoadingIndicator(message: 'Loading machines...'),
                        )
                      else if (viewModel.hasError)
                        _buildError(viewModel)
                      else if (viewModel.listings.isEmpty)
                        _buildEmpty()
                      else
                        _buildGrid(viewModel),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ListingsViewModel viewModel) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.error_outline, size: 48, color: AppColors.gray300),
          const SizedBox(height: 16),
          Text(
            viewModel.modelError.toString(),
            style: GoogleFonts.titilliumWeb(
              fontSize: 14,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: viewModel.init,
            child: Text(
              'Retry',
              style: GoogleFonts.titilliumWeb(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.inventory_2_outlined,
              size: 48, color: AppColors.gray300),
          const SizedBox(height: 16),
          Text(
            'No listings found',
            style: GoogleFonts.titilliumWeb(
              fontSize: 14,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(ListingsViewModel viewModel) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: viewModel.listings.length,
      itemBuilder: (context, index) {
        final listing = viewModel.listings[index];
        return MachineCard(
          listing: listing,
          onTap: () => viewModel.openListingDetail(listing.id),
        );
      },
    );
  }

  @override
  ListingsViewModel viewModelBuilder(BuildContext context) =>
      ListingsViewModel();

  @override
  void onViewModelReady(ListingsViewModel viewModel) => viewModel.init();
}
