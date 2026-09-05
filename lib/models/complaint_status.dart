enum ComplaintStatus {
  submitted(
    'Submitted',
    'Your complaint has been submitted successfully.',
  ),

  underReview(
    'Under Review',
    'Your complaint is being reviewed by our team.',
  ),

  inProgress(
    'In Progress',
    'An investigation is currently in progress.',
  ),

  resolved(
    'Resolved',
    'Your complaint has been resolved.',
  ),

  closed(
    'Closed',
    'This complaint has been closed.',
  );

  const ComplaintStatus(
      this.label,
      this.description,
      );

  // ==========================================================
  // LABEL
  // ==========================================================

  final String label;

  // ==========================================================
  // DESCRIPTION
  // ==========================================================

  final String description;

  // ==========================================================
  // FIRESTORE VALUE
  // ==========================================================

  String get firestoreValue {
    switch (this) {
      case ComplaintStatus.submitted:
        return 'submitted';

      case ComplaintStatus.underReview:
        return 'under_review';

      case ComplaintStatus.inProgress:
        return 'in_progress';

      case ComplaintStatus.resolved:
        return 'resolved';

      case ComplaintStatus.closed:
        return 'closed';
    }
  }

  // ==========================================================
  // DISPLAY
  // ==========================================================

  String get displayName {
    return label;
  }

  String get statusDescription {
    return description;
  }

  // ==========================================================
  // CHECKS
  // ==========================================================

  bool get isSubmitted {
    return this == ComplaintStatus.submitted;
  }

  bool get isUnderReview {
    return this == ComplaintStatus.underReview;
  }

  bool get isInProgress {
    return this == ComplaintStatus.inProgress;
  }

  bool get isResolved {
    return this == ComplaintStatus.resolved;
  }

  bool get isClosed {
    return this == ComplaintStatus.closed;
  }
}

// ============================================================
// EXTENSION
// ============================================================

extension ComplaintStatusExtension
on ComplaintStatus {
  static ComplaintStatus fromFirestoreValue(
      dynamic value,
      ) {
    final normalized =
        value
            ?.toString()
            .trim()
            .toLowerCase() ??
            '';

    switch (normalized) {
      case 'submitted':
        return ComplaintStatus.submitted;

      case 'under_review':
      case 'underreview':
      case 'under review':
        return ComplaintStatus.underReview;

      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return ComplaintStatus.inProgress;

      case 'resolved':
        return ComplaintStatus.resolved;

      case 'closed':
        return ComplaintStatus.closed;

      default:
        return ComplaintStatus.submitted;
    }
  }
}