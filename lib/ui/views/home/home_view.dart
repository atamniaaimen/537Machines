import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../widgets/machine_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: viewModel.isBusy
          ? const LoadingIndicator(message: 'Loading...')
          : RefreshIndicator(
              onRefresh: viewModel.init,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(context, viewModel),
                    verticalSpaceLarge,
                    _buildCategoryGrid(context, viewModel),
                    verticalSpaceLarge,
                    _buildFeaturedSection(context, viewModel),
                    verticalSpaceLarge,
                    _buildCtaBanner(context, viewModel),
                    verticalSpaceLarge,
                    _buildRecentSection(context, viewModel),
                    verticalSpaceLarge,
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroSection(BuildContext context, HomeViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A9B4F), Color(0xFF2ECC71)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '537',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'MACHINES',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Find Your Next\nMachine',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Industrial equipment marketplace',
                style: GoogleFonts.titilliumWeb(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              // Search bar
              GestureDetector(
                onTap: () => viewModel.onSearchSubmitted(''),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: AppColors.gray400, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Search machines, brands...',
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 15,
                          color: AppColors.gray300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, HomeViewModel viewModel) {
    final categoryIcons = <String, IconData>{
      'CNC Machines': Icons.precision_manufacturing,
      'Lathes': Icons.rotate_right,
      'Milling Machines': Icons.build,
      'Drilling Machines': Icons.hardware,
      'Grinding Machines': Icons.grain,
      'Welding Equipment': Icons.local_fire_department,
      'Compressors': Icons.air,
      'Generators': Icons.bolt,
      'Pumps': Icons.water_drop,
      'Conveyor Systems': Icons.conveyor_belt,
      'Packaging Machines': Icons.inventory_2,
      'Printing Machines': Icons.print,
      'Woodworking': Icons.forest,
      'Construction Equipment': Icons.construction,
      'Agricultural Machinery': Icons.agriculture,
      'Other': Icons.category,
    };

    final displayCategories = viewModel.categories.take(8).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CATEGORIES', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              final cat = displayCategories[index];
              final icon = categoryIcons[cat] ?? Icons.category;
              return GestureDetector(
                onTap: () => viewModel.onCategoryTapped(cat),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray150),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryPale,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            Icon(icon, size: 20, color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.split(' ').first,
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(
      BuildContext context, HomeViewModel viewModel) {
    if (viewModel.featuredListings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text('FEATURED LISTINGS', style: AppTextStyles.sectionLabel),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: viewModel.featuredListings.length,
            itemBuilder: (context, index) {
              final listing = viewModel.featuredListings[index];
              return Padding(
                padding: EdgeInsets.only(
                    right:
                        index < viewModel.featuredListings.length - 1 ? 16 : 0),
                child: SizedBox(
                  width: 220,
                  child: MachineCard(
                    listing: listing,
                    onTap: () => viewModel.onListingTapped(listing.id),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCtaBanner(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D3436), Color(0xFF636E72)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ready to Sell?',
              style: GoogleFonts.titilliumWeb(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'List your industrial equipment and reach thousands of buyers.',
              style: GoogleFonts.titilliumWeb(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: 'Create Listing',
              size: ButtonSize.md,
              onTap: viewModel.navigateToCreateListing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSection(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.recentListings.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RECENTLY ADDED', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: viewModel.recentListings.length,
            itemBuilder: (context, index) {
              final listing = viewModel.recentListings[index];
              return MachineCard(
                listing: listing,
                onTap: () => viewModel.onListingTapped(listing.id),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) => viewModel.init();
}
