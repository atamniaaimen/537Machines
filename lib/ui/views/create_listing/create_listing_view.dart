import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../common/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/constants/app_constants.dart';
import 'create_listing_viewmodel.dart';

class CreateListingView extends StackedView<CreateListingViewModel> {
  const CreateListingView({super.key});

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget builder(
    BuildContext context,
    CreateListingViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Listing'),
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
              // Photos section
              Text('PHOTOS', style: AppTextStyles.sectionLabel),
              verticalSpaceSmall,

              // Upload area or thumbnails
              if (viewModel.pickedImages.isEmpty)
                GestureDetector(
                  onTap: viewModel.pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.gray300,
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.gray50,
                    ),
                    child: CustomPaint(
                      painter: _DashedBorderPainter(
                        color: AppColors.gray300,
                        radius: 12,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: AppColors.gray400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to upload photos',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.gray400),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Max ${AppConstants.maxImages} photos',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...viewModel.pickedImages.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  viewModel.pickedImageBytes[entry.key],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () =>
                                      viewModel.removeImage(entry.key),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: AppColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      if (viewModel.pickedImages.length <
                          AppConstants.maxImages)
                        GestureDetector(
                          onTap: viewModel.pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.gray200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add,
                                color: AppColors.gray400, size: 28),
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
                label: 'Title',
                hint: 'e.g. CNC Milling Machine',
                onChanged: viewModel.setTitle,
                validator: (v) => Validators.validateRequired(v, 'Title'),
              ),
              verticalSpaceMedium,

              // Brand + Model row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Brand',
                      hint: 'e.g. Haas',
                      onChanged: viewModel.setBrand,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
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
                      validator: (v) =>
                          v == null ? 'Select condition' : null,
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,

              CustomTextField(
                label: 'Price (DZD)',
                hint: 'Enter price',
                keyboardType: TextInputType.number,
                onChanged: viewModel.setPrice,
                validator: Validators.validatePrice,
              ),
              verticalSpaceMedium,

              CustomTextField(
                label: 'Location',
                hint: 'e.g. New York, NY',
                onChanged: viewModel.setLocation,
                validator: (v) => Validators.validateRequired(v, 'Location'),
              ),
              verticalSpaceMedium,

              CustomTextField(
                label: 'Description',
                hint: 'Describe the machine, its features, and condition...',
                maxLines: 4,
                onChanged: viewModel.setDescription,
                validator: (v) =>
                    Validators.validateRequired(v, 'Description'),
              ),
              verticalSpaceMedium,

              _StyledDropdown(
                label: 'Category',
                value: viewModel.selectedCategory,
                items: AppConstants.categories,
                onChanged: viewModel.setCategory,
                validator: (v) =>
                    v == null ? 'Please select a category' : null,
              ),
              verticalSpaceMedium,

              CustomTextField(
                label: 'Serial Number',
                hint: 'Optional — machine serial number',
                onChanged: viewModel.setSerialNumber,
              ),
              verticalSpaceMedium,

              // Toggles
              _ToggleRow(
                label: 'Price is negotiable',
                value: viewModel.isNegotiable,
                onChanged: viewModel.toggleNegotiable,
              ),
              const SizedBox(height: 8),
              _ToggleRow(
                label: 'Accept offers from buyers',
                value: viewModel.acceptsOffers,
                onChanged: viewModel.toggleAcceptsOffers,
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

              CustomButton(
                title: 'Publish Listing',
                size: ButtonSize.lg,
                isLoading: viewModel.isBusy,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    viewModel.submit();
                  }
                },
              ),
              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  @override
  CreateListingViewModel viewModelBuilder(BuildContext context) =>
      CreateListingViewModel();
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
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.danger, width: 1.5),
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

// Dashed border painter for the upload area
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 8.0;
    const dashSpace = 4.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
            ),
            Switch(
              value: value,
              onChanged: (_) => onChanged(),
              activeColor: AppColors.primaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
