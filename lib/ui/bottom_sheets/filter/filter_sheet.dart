import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/listing_filter.dart';

class FilterSheet extends StatefulWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const FilterSheet({
    required this.request,
    required this.completer,
    super.key,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedSort;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _minYearController = TextEditingController();
  final _maxYearController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = widget.request.data as ListingFilter?;
    if (filter != null) {
      _selectedCategory = filter.category;
      _selectedCondition = filter.condition;
      _selectedSort = filter.sortBy;
      if (filter.minPrice != null) {
        _minPriceController.text = filter.minPrice!.toStringAsFixed(0);
      }
      if (filter.maxPrice != null) {
        _maxPriceController.text = filter.maxPrice!.toStringAsFixed(0);
      }
      if (filter.minYear != null) {
        _minYearController.text = filter.minYear.toString();
      }
      if (filter.maxYear != null) {
        _maxYearController.text = filter.maxYear.toString();
      }
      if (filter.locationFilter != null) {
        _locationController.text = filter.locationFilter!;
      }
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minYearController.dispose();
    _maxYearController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _selectedCategory = null;
      _selectedCondition = null;
      _selectedSort = null;
      _minPriceController.clear();
      _maxPriceController.clear();
      _minYearController.clear();
      _maxYearController.clear();
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: AppTextStyles.heading2),
                GestureDetector(
                  onTap: _resetAll,
                  child: Text(
                    'Reset All',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,

            // Category
            _FilterDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: AppConstants.categories,
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            verticalSpaceMedium,

            // Condition
            _FilterDropdown(
              label: 'Condition',
              value: _selectedCondition,
              items: AppConstants.conditions,
              onChanged: (v) => setState(() => _selectedCondition = v),
            ),
            verticalSpaceMedium,

            // Price range
            Text('PRICE RANGE', style: AppTextStyles.fieldLabel),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FilterTextField(
                    controller: _minPriceController,
                    hint: 'Min',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—',
                      style: TextStyle(color: AppColors.gray400, fontSize: 16)),
                ),
                Expanded(
                  child: _FilterTextField(
                    controller: _maxPriceController,
                    hint: 'Max',
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,

            // Year range
            Text('YEAR RANGE', style: AppTextStyles.fieldLabel),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _FilterTextField(
                    controller: _minYearController,
                    hint: 'From',
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('—',
                      style: TextStyle(color: AppColors.gray400, fontSize: 16)),
                ),
                Expanded(
                  child: _FilterTextField(
                    controller: _maxYearController,
                    hint: 'To',
                  ),
                ),
              ],
            ),
            verticalSpaceMedium,

            // Location
            Text('LOCATION', style: AppTextStyles.fieldLabel),
            const SizedBox(height: 8),
            _FilterTextField(
              controller: _locationController,
              hint: 'e.g. New York',
              keyboardType: TextInputType.text,
            ),
            verticalSpaceMedium,

            // Sort by
            _FilterDropdown(
              label: 'Sort By',
              value: _selectedSort,
              items: AppConstants.sortOptions,
              onChanged: (v) => setState(() => _selectedSort = v),
            ),

            verticalSpaceLarge,

            // Apply button
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final filter = ListingFilter(
                    category: _selectedCategory,
                    condition: _selectedCondition,
                    minPrice: double.tryParse(_minPriceController.text),
                    maxPrice: double.tryParse(_maxPriceController.text),
                    minYear: int.tryParse(_minYearController.text),
                    maxYear: int.tryParse(_maxYearController.text),
                    locationFilter: _locationController.text.isNotEmpty
                        ? _locationController.text.trim()
                        : null,
                    sortBy: _selectedSort,
                  );
                  widget.completer(SheetResponse(
                    confirmed: true,
                    data: filter,
                  ));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Apply Filters',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.buttonLg,
                  ),
                ),
              ),
            ),
            verticalSpaceSmall,
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
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
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text('All')),
            ...items.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _FilterTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.number,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.gray300),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gray200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
