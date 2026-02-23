import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              backgroundColor: AppColors.gray200,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: GoogleFonts.titilliumWeb(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: AppColors.gray400,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
