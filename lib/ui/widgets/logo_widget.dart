import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/app_colors.dart';

enum LogoSize { sm, lg }

class LogoWidget extends StatelessWidget {
  final LogoSize size;

  const LogoWidget({this.size = LogoSize.sm, super.key});

  @override
  Widget build(BuildContext context) {
    final isLg = size == LogoSize.lg;
    final height = isLg ? 56.0 : 36.0;
    final numFontSize = isLg ? 26.0 : 16.0;
    final textFontSize = isLg ? 8.0 : 6.0;
    final numPadH = isLg ? 16.0 : 8.0;
    final textPadH = isLg ? 12.0 : 8.0;
    final textSpacing = isLg ? 2.0 : 1.5;
    final radius = isLg ? 12.0 : 8.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: numPadH),
              alignment: Alignment.center,
              child: Text(
                '537',
                style: GoogleFonts.titilliumWeb(
                  fontSize: numFontSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkest,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              color: AppColors.dark,
              padding: EdgeInsets.symmetric(horizontal: textPadH),
              alignment: Alignment.center,
              child: Text(
                'MACHINES',
                style: GoogleFonts.titilliumWeb(
                  fontSize: textFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: textSpacing,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
