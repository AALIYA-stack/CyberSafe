import 'package:flutter/material.dart';

import '../models/complaint.dart';
import 'status_chip.dart';

class ComplaintCard extends StatefulWidget {
  final Complaint complaint;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
  });

  @override
  State<ComplaintCard> createState() =>
      _ComplaintCardState();
}

class _ComplaintCardState
    extends State<ComplaintCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 450),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _date(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Card(
          margin:
          const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius:
            BorderRadius.circular(18),
            child: Padding(
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.complaint.title,
                              style: Theme.of(
                                  context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                                height: 5),
                            Text(
                              widget.complaint.id,
                              style: Theme.of(
                                  context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        status:
                        widget.complaint.status,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 17,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          widget.complaint.category,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        _date(
                          widget.complaint
                              .submittedDate,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons
                            .arrow_forward_rounded,
                        size: 18,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}