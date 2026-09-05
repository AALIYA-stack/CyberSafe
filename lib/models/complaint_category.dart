import 'package:flutter/material.dart';

enum ComplaintCategory {
  onlineFraud(
    title: 'Online Fraud',
    description:
    'Report scams, fake online sellers, payment fraud and other online financial crimes.',
    icon: Icons.payments_outlined,
  ),

  cyberHarassment(
    title: 'Cyber Harassment',
    description:
    'Report unwanted, abusive or threatening online communication.',
    icon: Icons.chat_bubble_outline_rounded,
  ),

  hackingUnauthorizedAccess(
    title: 'Hacking / Unauthorized Access',
    description:
    'Report unauthorized access to your account, device or online service.',
    icon: Icons.security_outlined,
  ),

  identityTheft(
    title: 'Identity Theft',
    description:
    'Report misuse or unauthorized use of your personal identity or information.',
    icon: Icons.person_search_outlined,
  ),

  fakeImpersonationAccount(
    title: 'Fake / Impersonation Account',
    description:
    'Report fake profiles or accounts pretending to be another person.',
    icon: Icons.account_circle_outlined,
  ),

  blackmailExtortion(
    title: 'Blackmail / Extortion',
    description:
    'Report online blackmail, coercion or extortion attempts.',
    icon: Icons.warning_amber_outlined,
  ),

  phishingScam(
    title: 'Phishing / Scam',
    description:
    'Report suspicious links, messages, emails or websites attempting to steal information.',
    icon: Icons.phishing_outlined,
  ),

  financialScam(
    title: 'Financial Scam',
    description:
    'Report suspicious financial transactions, payment scams or fraudulent activities.',
    icon: Icons.account_balance_wallet_outlined,
  ),

  dataTheft(
    title: 'Data Theft',
    description:
    'Report unauthorized collection, access or misuse of personal or digital data.',
    icon: Icons.storage_outlined,
  ),

  otherCyberCrime(
    title: 'Other Cyber Crime',
    description:
    'Report a cyber crime that does not fit into the categories above.',
    icon: Icons.more_horiz_rounded,
  );

  final String title;
  final String description;
  final IconData icon;

  const ComplaintCategory({
    required this.title,
    required this.description,
    required this.icon,
  });
}