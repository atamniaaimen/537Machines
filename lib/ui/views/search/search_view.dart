import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import 'search_viewmodel.dart';

class SearchView extends StackedView<SearchViewModel> {
  const SearchView({super.key});

  @override
  Widget builder(
    BuildContext context,
    SearchViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'Search',
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
  SearchViewModel viewModelBuilder(BuildContext context) => SearchViewModel();
}
