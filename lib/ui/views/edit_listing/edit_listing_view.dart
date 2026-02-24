import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../common/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';
import '../../../core/constants/app_constants.dart';
import 'edit_listing_viewmodel.dart';

class EditListingView extends StackedView<EditListingViewModel> {
  final String listingId;

  const EditListingView({required this.listingId, super.key});

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget builder(
    BuildContext context,
    EditListingViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy && viewModel.listing == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: LoadingIndicator(message: 'Loading listing...'),
      );
    }

    if (viewModel.listing == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Edit Listing'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.dark,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: const Center(child: Text('Could not load listing')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Listing'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.gray150),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photos section — compact thumbnail row
              Text('PHOTOS', style: AppTextStyles.sectionLabel),
              verticalSpaceSmall,
              SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Existing remote images
                    ...viewModel.existingImageUrls.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: entry.value,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  width: 64,
                                  height: 64,
                                  color: AppColors.gray100,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () =>
                                    viewModel.removeExistingImage(entry.key),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // New local images
                    ...viewModel.newImages.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                viewModel.newImageBytes[entry.key],
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () =>
                                    viewModel.removeNewImage(entry.key),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (viewModel.totalImageCount < AppConstants.maxImages)
                      GestureDetector(
                        onTap: viewModel.pickImage,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.gray200),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add,
                              color: AppColors.gray400, size: 24),
                        ),
                      ),
                  ],
                ),
              ),

              verticalSpaceLarge,

              // Machine Details section
              Text('MACHINE DETAILS', style: AppTextStyles.sectionLabel),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.title,
                label: 'Title',
                onChanged: viewModel.setTitle,
                validator: (v) => Validators.validateRequired(v, 'Title'),
              ),
              verticalSpaceMedium,

              // Brand + Model row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      initialValue: viewModel.brand,
                      label: 'Brand',
                      hint: 'e.g. Haas',
                      onChanged: viewModel.setBrand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      initialValue: viewModel.model,
                      label: 'Model',
                      hint: 'e.g. VF-2',
                      onChanged: viewModel.setModel,
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Year + Condition row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      initialValue: viewModel.year,
                      label: 'Year',
                      hint: 'e.g. 2020',
                      keyboardType: TextInputType.number,
                      onChanged: viewModel.setYear,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StyledDropdown(
                      label: 'Condition',
                      value: viewModel.selectedCondition,
                      items: AppConstants.conditions,
                      onChanged: viewModel.setCondition,
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Hours + Category row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      initialValue: viewModel.hours,
                      label: 'Hours',
                      hint: 'e.g. 5000',
                      keyboardType: TextInputType.number,
                      onChanged: viewModel.setHours,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StyledDropdown(
                      label: 'Category',
                      value: viewModel.selectedCategory,
                      items: AppConstants.categories,
                      onChanged: viewModel.setCategory,
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.price,
                label: 'Price (DZD)',
                keyboardType: TextInputType.number,
                onChanged: viewModel.setPrice,
                validator: Validators.validatePrice,
              ),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.location,
                label: 'Location',
                onChanged: viewModel.setLocation,
                validator: (v) => Validators.validateRequired(v, 'Location'),
              ),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.description,
                label: 'Description',
                maxLines: 4,
                onChanged: viewModel.setDescription,
                validator: (v) => Validators.validateRequired(v, 'Description'),
              ),

              verticalSpaceLarge,

              if (viewModel.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    viewModel.modelError.toString(),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Save + Delete buttons row
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      title: 'Save Changes',
                      size: ButtonSize.lg,
                      isLoading: viewModel.isBusy,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          viewModel.submit();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomButton(
                    title: 'Delete',
                    variant: ButtonVariant.danger,
                    size: ButtonSize.lg,
                    onTap: viewModel.deleteListing,
                  ),
                ],
              ),
              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  @override
  EditListingViewModel viewModelBuilder(BuildContext context) =>
      EditListingViewModel(listingId: listingId);

  @override
  void onViewModelReady(EditListingViewModel viewModel) => viewModel.init();
}

// Styled dropdown to match the 537 design
class _StyledDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const _StyledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.gray200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
          ),
          items: items.map((c) {
            return DropdownMenuItem(value: c, child: Text(c));
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
