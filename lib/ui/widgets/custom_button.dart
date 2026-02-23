import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../common/app_colors.dart';

enum ButtonVariant { primary, outline, ghost, danger }
enum ButtonSize { sm, md, lg }

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  final ButtonVariant variant;
  final ButtonSize size;
  final double? width;
  final IconData? icon;

  const CustomButton({
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.width,
    this.icon,
    super.key,
  });

  EdgeInsets get _padding {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 14);
    }
  }

  double get _fontSize {
    switch (size) {
      case ButtonSize.sm:
        return 12;
      case ButtonSize.md:
        return 14;
      case ButtonSize.lg:
        return 16;
    }
  }

  Color get _bgColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.danger:
        return Colors.transparent;
    }
  }

  Color get _borderColor {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.outline:
        return AppColors.primary;
      case ButtonVariant.ghost:
        return AppColors.gray200;
      case ButtonVariant.danger:
        return AppColors.danger;
    }
  }

  Color get _textColor {
    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.outline:
        return AppColors.primaryDark;
      case ButtonVariant.ghost:
        return AppColors.gray500;
      case ButtonVariant.danger:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.titilliumWeb(
      fontSize: _fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: _textColor,
    );

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(_textColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _fontSize + 4, color: _textColor),
                const SizedBox(width: 8),
              ],
              Text(title, style: textStyle),
            ],
          );

    return SizedBox(
      width: width ?? double.infinity,
      child: Material(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: _padding,
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
