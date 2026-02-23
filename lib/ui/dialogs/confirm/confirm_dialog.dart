import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';

class ConfirmDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ConfirmDialog({
    required this.request,
    required this.completer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDestructive = request.variant == null ||
        request.title?.toLowerCase().contains('delete') == true;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.danger.withAlpha(25)
                    : AppColors.primaryPale,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDestructive
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 32,
                color: isDestructive ? AppColors.danger : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              request.title ?? 'Confirm',
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              request.description ?? 'Are you sure?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
            ),
            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          completer(DialogResponse(confirmed: false)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          request.secondaryButtonTitle ?? 'Cancel',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.button
                              .copyWith(color: AppColors.gray500),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () =>
                          completer(DialogResponse(confirmed: true)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDestructive
                              ? AppColors.danger
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          request.mainButtonTitle ?? 'Confirm',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
