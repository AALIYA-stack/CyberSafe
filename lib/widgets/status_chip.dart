import 'package:flutter/material.dart';

import '../models/complaint_status.dart';

class StatusChip extends StatelessWidget {
  final ComplaintStatus status;

  const StatusChip({
    super.key,
    required this.status,
  });

  Color _color(BuildContext context) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Colors.blue;

      case ComplaintStatus.underReview:
        return Colors.orange;

      case ComplaintStatus.inProgress:
        return Colors.indigo;

      case ComplaintStatus.resolved:
        return Colors.green;

      case ComplaintStatus.closed:
        return Colors.grey;
    }
  }

  IconData _icon() {
    switch (status) {
      case ComplaintStatus.submitted:
        return Icons.send_outlined;

      case ComplaintStatus.underReview:
        return Icons.visibility_outlined;

      case ComplaintStatus.inProgress:
        return Icons.sync_rounded;

      case ComplaintStatus.resolved:
        return Icons.check_circle_outline;

      case ComplaintStatus.closed:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon(),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}