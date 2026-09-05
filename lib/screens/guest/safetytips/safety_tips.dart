import '../../../models/safety_tips.dart';

/// Mock safety tips data.
///
/// This data is kept for compatibility with existing frontend
/// references. The actual Safety Tips screen can load data
/// from Firebase through SafetyTipsService.
class SafetyTipsData {
  SafetyTipsData._();

  static const List<SafetyTip> tips = <SafetyTip>[
    SafetyTip(
      title: 'Use strong unique passwords.',
      description:
      'Use long and unique passwords for your important accounts. Avoid easily guessable information.',
      category: 'Account Security',
      icon: 'lock',
    ),
    SafetyTip(
      title: 'Enable two-factor authentication.',
      description:
      'Enable two-factor authentication whenever it is available to add an extra layer of account protection.',
      category: 'Account Security',
      icon: 'verified_user',
    ),
    SafetyTip(
      title: 'Never share OTP codes.',
      description:
      'Never share OTPs, verification codes or passwords with anyone.',
      category: 'Account Security',
      icon: 'sms',
    ),
    SafetyTip(
      title: 'Verify suspicious links before clicking.',
      description:
      'Check links carefully before opening them, especially when they come from unknown sources.',
      category: 'Device Security',
      icon: 'link',
    ),
    SafetyTip(
      title: 'Avoid downloading unknown files.',
      description:
      'Download applications and files only from trusted sources and official stores.',
      category: 'Device Security',
      icon: 'file_download',
    ),
    SafetyTip(
      title: 'Keep apps updated regularly.',
      description:
      'Keep your operating system and applications updated to receive security fixes.',
      category: 'Device Security',
      icon: 'system_update',
    ),
    SafetyTip(
      title: 'Do not share sensitive personal information.',
      description:
      'Avoid sharing passwords, financial information, CNIC details or other sensitive information online.',
      category: 'Privacy',
      icon: 'privacy_tip',
    ),
    SafetyTip(
      title: 'Report suspicious accounts.',
      description:
      'Report suspicious or fake accounts through the appropriate platform reporting tools.',
      category: 'Social Media Safety',
      icon: 'report',
    ),
    SafetyTip(
      title: 'Use privacy settings on social media.',
      description:
      'Review your social media privacy settings and limit who can access your information.',
      category: 'Social Media Safety',
      icon: 'settings',
    ),
    SafetyTip(
      title: 'Avoid public Wi-Fi for banking.',
      description:
      'Avoid using unsecured public Wi-Fi when accessing banking or other sensitive accounts.',
      category: 'Financial Safety',
      icon: 'wifi_off',
    ),
    SafetyTip(
      title: 'Never pay upfront for a prize or job.',
      description:
      'Be careful of scams that ask you to pay money before receiving a prize, job or service.',
      category: 'Financial Safety',
      icon: 'money_off',
    ),
    SafetyTip(
      title: 'Regularly check for unknown devices on your accounts.',
      description:
      'Review active sessions and connected devices and remove devices you do not recognize.',
      category: 'Account Security',
      icon: 'devices',
    ),
  ];

  static List<String> categories() {
    final List<String> list = <String>[];
    for (final SafetyTip tip in tips) {
    if (!list.contains(tip.category)) {
    list.add(tip.category);
    }
    }

    return list;

  }
}
