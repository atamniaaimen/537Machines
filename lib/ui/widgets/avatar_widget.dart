import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/app_colors.dart';

enum AvatarSize { sm, md, lg }

class AvatarWidget extends StatelessWidget {
  final String initials;
  final String? photoUrl;
  final AvatarSize size;

  const AvatarWidget({
    required this.initials,
    this.photoUrl,
    this.size = AvatarSize.md,
    super.key,
  });

  double get _size {
    switch (size) {
      case AvatarSize.sm:
        return 44;
      case AvatarSize.md:
        return 80;
      case AvatarSize.lg:
        return 100;
    }
  }

  double get _fontSize {
    switch (size) {
      case AvatarSize.sm:
        return 16;
      case AvatarSize.md:
        return 28;
      case AvatarSize.lg:
        return 36;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasPhoto ? AppColors.gray200 : AppColors.primaryPale,
        image: hasPhoto
            ? DecorationImage(
                image: CachedNetworkImageProvider(photoUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: hasPhoto
          ? null
          : Center(
              child: Text(
                initials,
                style: GoogleFonts.titilliumWeb(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
    );
  }
}
