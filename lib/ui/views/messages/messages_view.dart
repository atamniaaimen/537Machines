import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import 'messages_viewmodel.dart';

class MessagesView extends StackedView<MessagesViewModel> {
  const MessagesView({super.key});

  @override
  Widget builder(
    BuildContext context,
    MessagesViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'Messages',
              style: GoogleFonts.titilliumWeb(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: GoogleFonts.titilliumWeb(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  MessagesViewModel viewModelBuilder(BuildContext context) =>
      MessagesViewModel();
}
