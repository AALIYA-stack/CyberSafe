import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
        loading ? null : onPressed,
        child: loading
            ? const SizedBox(
          width: 21,
          height: 21,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
              ),
              const SizedBox(
                width: 8,
              ),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}