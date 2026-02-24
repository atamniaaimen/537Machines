import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../common/app_colors.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/machine_card.dart';
import '../../../core/utils/date_formatter.dart';
import 'listing_detail_viewmodel.dart';

class ListingDetailView extends StackedView<ListingDetailViewModel> {
  final String listingId;

  const ListingDetailView({required this.listingId, super.key});

  @override
  Widget builder(
    BuildContext context,
    ListingDetailViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading listing...'),
      );
    }

    if (viewModel.hasError || viewModel.listing == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Listing Detail')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: AppColors.gray300),
              const SizedBox(height: 16),
              Text('Could not load listing',
                  style: GoogleFonts.titilliumWeb(color: AppColors.gray400)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: viewModel.init,
                child: Text('Retry',
                    style: GoogleFonts.titilliumWeb(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark)),
              ),
            ],
          ),
        ),
      );
    }

    final listing = viewModel.listing!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back,
                        size: 22, color: AppColors.gray500),
                  ),
                  Text(
                    'Listing Detail',
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (viewModel.isOwner) ...[
                        GestureDetector(
                          onTap: viewModel.navigateToEdit,
                          child: const Icon(Icons.edit_outlined,
                              size: 20, color: AppColors.gray500),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: viewModel.deleteListing,
                          child: const Icon(Icons.delete_outline,
                              size: 20, color: AppColors.danger),
                        ),
                      ] else
                        GestureDetector(
                          onTap: viewModel.toggleFavorite,
                          child: Icon(
                            viewModel.isFavorited
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 22,
                            color: viewModel.isFavorited
                                ? AppColors.danger
                                : AppColors.gray500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carousel
                    _buildCarousel(listing),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge + time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _conditionBadge(listing.condition),
                              Text(
                                'Listed ${DateFormatter.timeAgo(listing.createdAt)}',
                                style: GoogleFonts.titilliumWeb(
                                  fontSize: 12,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Text(
                            listing.title,
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.dark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Price
                          Text(
                            '${_formatPrice(listing.price)} DZD',
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),

                          _divider(),

                          // Specifications
                          _sectionLabel('Specifications'),
                          const SizedBox(height: 12),
                          _specsGrid(listing),
                          const SizedBox(height: 24),

                          // Description
                          _sectionLabel('Description'),
                          const SizedBox(height: 12),
                          Text(
                            listing.description,
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 14,
                              color: AppColors.gray500,
                              height: 1.8,
                            ),
                          ),

                          _divider(),

                          // Seller
                          _sectionLabel('Seller'),
                          const SizedBox(height: 12),
                          _sellerCard(listing),
                          const SizedBox(height: 24),

                          // Action buttons
                          if (!viewModel.isOwner) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    title: 'Contact Seller',
                                    size: ButtonSize.lg,
                                    isLoading: viewModel.isBusy,
                                    onTap: viewModel.contactSeller,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                CustomButton(
                                  title: 'Make Offer',
                                  variant: ButtonVariant.outline,
                                  size: ButtonSize.md,
                                  width: 140,
                                  onTap: () => _showOfferDialog(
                                      context, viewModel, listing.price),
                                ),
                              ],
                            ),
                          ],

                          // Similar machines
                          if (viewModel.similarListings.isNotEmpty) ...[
                            _divider(),
                            _sectionLabel('Similar Machines'),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),

                    // Similar machines horizontal scroll
                    if (viewModel.similarListings.isNotEmpty)
                      SizedBox(
                        height: 260,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: viewModel.similarListings.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final similar = viewModel.similarListings[index];
                            return SizedBox(
                              width: 200,
                              child: MachineCard(
                                listing: similar,
                                onTap: () =>
                                    viewModel.openListingDetail(similar.id),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(listing) {
    if (listing.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Icon(Icons.precision_manufacturing,
                size: 64, color: AppColors.dark.withOpacity(0.1)),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: CarouselSlider(
        options: CarouselOptions(
          aspectRatio: 16 / 10,
          viewportFraction: 1.0,
          enableInfiniteScroll: listing.imageUrls.length > 1,
        ),
        items: listing.imageUrls.map<Widget>((url) {
          return CachedNetworkImage(
            imageUrl: url,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: AppColors.gray100,
              child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.gray100,
              child: const Icon(Icons.broken_image, size: 48),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _conditionBadge(String condition) {
    Color bg;
    Color textColor;
    final lower = condition.toLowerCase();
    if (lower == 'new') {
      bg = AppColors.conditionNew;
      textColor = AppColors.conditionNewText;
    } else if (lower == 'used') {
      bg = AppColors.conditionUsed;
      textColor = AppColors.conditionUsedText;
    } else {
      bg = AppColors.conditionRefurb;
      textColor = AppColors.conditionRefurbText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        condition.toUpperCase(),
        style: GoogleFonts.titilliumWeb(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: textColor,
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.titilliumWeb(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 3,
        color: AppColors.gray400,
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: AppColors.gray150,
      margin: const EdgeInsets.symmetric(vertical: 20),
    );
  }

  Widget _specsGrid(listing) {
    final specs = <MapEntry<String, String>>[
      MapEntry('Brand', listing.brand.isNotEmpty ? listing.brand : '—'),
      MapEntry('Model', listing.model.isNotEmpty ? listing.model : '—'),
      MapEntry('Year', listing.year?.toString() ?? '—'),
      MapEntry('Condition', listing.condition),
      MapEntry('Location', listing.location),
      MapEntry('Hours', listing.hours?.toString() ?? '—'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: specs.map((spec) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            border: Border.all(color: AppColors.gray150),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                spec.key.toUpperCase(),
                style: GoogleFonts.titilliumWeb(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                spec.value,
                style: GoogleFonts.titilliumWeb(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sellerCard(listing) {
    final initials = listing.sellerName.isNotEmpty
        ? listing.sellerName
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        border: Border.all(color: AppColors.gray150),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          AvatarWidget(initials: initials, size: AvatarSize.sm),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.sellerName,
                  style: GoogleFonts.titilliumWeb(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Member',
                  style: GoogleFonts.titilliumWeb(
                    fontSize: 12,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            title: 'View',
            variant: ButtonVariant.outline,
            size: ButtonSize.sm,
            width: 70,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0);
      final buffer = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        buffer.write(formatted[i]);
        count++;
        if (count % 3 == 0 && i != 0) buffer.write(',');
      }
      return buffer.toString().split('').reversed.join();
    }
    return price.toStringAsFixed(0);
  }

  void _showOfferDialog(
      BuildContext context, ListingDetailViewModel viewModel, double askingPrice) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Make an Offer',
          style: GoogleFonts.titilliumWeb(
            fontWeight: FontWeight.w700,
            color: AppColors.dark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asking price: ${_formatPrice(askingPrice)} DZD',
              style: GoogleFonts.titilliumWeb(
                fontSize: 13,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.titilliumWeb(fontSize: 16, color: AppColors.dark),
              decoration: InputDecoration(
                labelText: 'Your offer (DZD)',
                labelStyle: GoogleFonts.titilliumWeb(color: AppColors.gray400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryDark),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.titilliumWeb(color: AppColors.gray400),
            ),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              if (amount != null && amount > 0) {
                Navigator.of(ctx).pop();
                viewModel.makeOffer(amount);
              }
            },
            child: Text(
              'Submit Offer',
              style: GoogleFonts.titilliumWeb(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ListingDetailViewModel viewModelBuilder(BuildContext context) =>
      ListingDetailViewModel(listingId: listingId);

  @override
  void onViewModelReady(ListingDetailViewModel viewModel) => viewModel.init();
}
