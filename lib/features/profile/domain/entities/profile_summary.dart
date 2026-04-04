class ProfileSummary {
  const ProfileSummary({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    required this.membership,
    required this.nextBillingDate,
    required this.benefits,
  });

  final String name;
  final String role;
  final String phone;
  final String email;
  final String membership;
  final String nextBillingDate;
  final List<String> benefits;
}

class ProfileSubscriptionSnapshot {
  const ProfileSubscriptionSnapshot({
    required this.planCode,
    required this.status,
    required this.documentRemaining,
    required this.pdfRemaining,
  });

  final String planCode;
  final String status;
  final int documentRemaining;
  final int pdfRemaining;
}
