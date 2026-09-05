import 'package:flutter/material.dart';

import '../models/complaint_status.dart';

class StatusBadge extends StatelessWidget {
final ComplaintStatus status;

const StatusBadge({
super.key,
required this.status,
});

// ==========================================================
// BACKGROUND COLOR
// ==========================================================

Color _backgroundColor() {
switch (status) {
case ComplaintStatus.submitted:
return Colors.blue.withValues(alpha: 0.10);

case ComplaintStatus.underReview:
return Colors.orange.withValues(alpha: 0.12);

case ComplaintStatus.inProgress:
return Colors.deepPurple.withValues(alpha: 0.10);

case ComplaintStatus.resolved:
return Colors.green.withValues(alpha: 0.10);

case ComplaintStatus.closed:
return Colors.grey.withValues(alpha: 0.12);
}
}

// ==========================================================
// TEXT COLOR
// ==========================================================

Color _textColor() {
switch (status) {
case ComplaintStatus.submitted:
return Colors.blue;

case ComplaintStatus.underReview:
return Colors.orange.shade800;

case ComplaintStatus.inProgress:
return Colors.deepPurple;

case ComplaintStatus.resolved:
return Colors.green.shade700;

case ComplaintStatus.closed:
return Colors.grey.shade700;
}
}

// ==========================================================
// ICON
// ==========================================================

IconData _icon() {
switch (status) {
case ComplaintStatus.submitted:
return Icons.send_rounded;

case ComplaintStatus.underReview:
return Icons.visibility_outlined;

case ComplaintStatus.inProgress:
return Icons.sync_rounded;

case ComplaintStatus.resolved:
return Icons.check_circle_outline_rounded;

case ComplaintStatus.closed:
return Icons.lock_outline_rounded;
}
}

// ==========================================================
// BUILD
// ==========================================================

@override
Widget build(BuildContext context) {
final textColor = _textColor();

return Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 8,
),
decoration: BoxDecoration(
color: _backgroundColor(),
borderRadius: BorderRadius.circular(12),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
_icon(),
size: 15,
color: textColor,
),

const SizedBox(width: 6),

Text(
status.label,
style: TextStyle(
color: textColor,
fontSize: 11,
fontWeight: FontWeight.w800,
),
),
],
),
);
}
}

