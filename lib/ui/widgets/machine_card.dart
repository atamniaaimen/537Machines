import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/app_colors.dart';
import '../../models/machine_listing.dart';

class MachineCard extends StatelessWidget {
  final MachineListing listing;
  final VoidCallback onTap;

  const MachineCard({
    required this.listing,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray150),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with condition badge
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (listing.imageUrls.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: listing.imageUrls.first,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.gray100,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.gray100,
                        child: const Icon(Icons.broken_image,
                            color: AppColors.gray300),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.gray100,
                      child: Center(
                        child: Icon(Icons.precision_manufacturing,
                            size: 40, color: AppColors.dark.withOpacity(0.15)),
                      ),
                    ),
                  // Condition badge
                  if (listing.condition.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _ConditionBadge(condition: listing.condition),
                    ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.titilliumWeb(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatPrice(listing.price)} DZD',
                      style: GoogleFonts.titilliumWeb(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.gray400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: AppColors.gray400,
                            ),
                          ),
                        ),
                        if (listing.year != null)
                          Text(
                            '${listing.year}',
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: AppColors.gray400,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
}

class _ConditionBadge extends StatelessWidget {
  final String condition;
  const _ConditionBadge({required this.condition});

  @override
  Widget build(BuildContext context) {
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
}
