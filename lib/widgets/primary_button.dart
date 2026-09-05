import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled =
        isLoading || onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed:
        disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          AppColors.primary,
          foregroundColor:
          Colors.white,
          disabledBackgroundColor:
          AppColors.primary.withValues(
            alpha: 0.55,
          ),
          disabledForegroundColor:
          Colors.white70,
          elevation: 0,
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(15),
          ),
        ),
        child: AnimatedSwitcher(
          duration:
          const Duration(
            milliseconds: 200,
          ),
          child: isLoading
              ? const SizedBox(
            key: ValueKey(
              'loading',
            ),
            width: 22,
            height: 22,
            child:
            CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
              AlwaysStoppedAnimation<
                  Color>(
                Colors.white,
              ),
            ),
          )
              : Row(
            key: const ValueKey(
              'content',
            ),
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                ),
                const SizedBox(
                  width: 9,
                ),
              ],
              Text(
                text,
                style:
                const TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}