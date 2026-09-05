import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../routes/app_routes.dart';

class AuthRequiredDialog extends StatelessWidget {
  final String title;
  final String message;

  const AuthRequiredDialog({
    super.key,
    this.title = 'Login Required',
    this.message =
    'Please profile or create an account to access this feature.',
  });

  static Future<void> show(
      BuildContext context, {
        String title = 'Login Required',
        String message =
        'Please profile or create an account to access this feature.',
      }) {
    return showDialog<void>(
      context: context,
      builder: (_) {
        return AuthRequiredDialog(
          title: title,
          message: message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(
        24,
        24,
        24,
        8,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        12,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.grey.shade600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);

            Navigator.pushNamed(
              context,
              AppRoutes.signup,
            );
          },
          child: const Text('Create Account'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);

            Navigator.pushNamed(
              context,
              AppRoutes.login,
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Login'),
        ),
      ],
    );
  }
}