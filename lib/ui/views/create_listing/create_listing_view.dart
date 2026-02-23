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

  @override
  Widget builder(
    BuildContext context,
    CreateListingViewModel viewModel,
    Widget? child,
  ) {
    final titleController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final priceController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
          key: formKey,
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
                                child: Image.file(
                                  entry.value,
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
                controller: titleController,
                label: 'Title',
                hint: 'e.g. CNC Milling Machine',
                validator: (v) => Validators.validateRequired(v, 'Title'),
              ),
              verticalSpaceMedium,

              // Brand + Model row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: brandController,
                      label: 'Brand',
                      hint: 'e.g. Haas',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: modelController,
                      label: 'Model',
                      hint: 'e.g. VF-2',
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
                      controller: yearController,
                      label: 'Year',
                      hint: 'e.g. 2020',
                      keyboardType: TextInputType.number,
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
                controller: priceController,
                label: 'Price (\$)',
                hint: 'Enter price',
                keyboardType: TextInputType.number,
                validator: Validators.validatePrice,
              ),
              verticalSpaceMedium,

              CustomTextField(
                controller: locationController,
                label: 'Location',
                hint: 'e.g. New York, NY',
                validator: (v) => Validators.validateRequired(v, 'Location'),
              ),
              verticalSpaceMedium,

              CustomTextField(
                controller: descriptionController,
                label: 'Description',
                hint: 'Describe the machine, its features, and condition...',
                maxLines: 4,
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
                  if (formKey.currentState!.validate()) {
                    viewModel.submit(
                      title: titleController.text.trim(),
                      brand: brandController.text.trim(),
                      model: modelController.text.trim(),
                      year: yearController.text.trim(),
                      description: descriptionController.text.trim(),
                      price: priceController.text.trim(),
                      location: locationController.text.trim(),
                    );
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
