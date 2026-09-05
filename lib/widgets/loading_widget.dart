import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child:
            CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),

          if (message != null) ...[
            const SizedBox(height: 14),

            Text(
              message!,
              style: TextStyle(
                fontSize: 13,
                color:
                Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}