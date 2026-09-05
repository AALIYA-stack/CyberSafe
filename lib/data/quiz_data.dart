import '../models/quiz_question.dart';

class QuizData {
QuizData._();

static const List<QuizQuestion> questions = [
// ==========================================================
// PHISHING & SCAMS
// ==========================================================

QuizQuestion(
category: 'Phishing & Scams',
question:
'You receive a message asking you to click an unknown link and enter your password. What should you do?',
options: [
'Click the link immediately',
'Enter your password to verify the account',
'Verify the source and avoid entering information through the suspicious link',
'Forward the message to everyone',
],
correctAnswerIndex: 2,
explanation:
'Suspicious links can lead to phishing pages. Verify the sender and website before entering sensitive information.',
),

QuizQuestion(
category: 'Phishing & Scams',
question:
'Which sign may indicate a phishing message?',
options: [
'A normal conversation with a known person',
'An unexpected request for sensitive information with urgent language',
'A message you recently requested',
'A routine notification from a trusted app',
],
correctAnswerIndex: 1,
explanation:
'Unexpected requests for sensitive information combined with urgency are common warning signs of phishing.',
),

QuizQuestion(
category: 'Phishing & Scams',
question:
'What should you do if an email claims your account will be closed unless you act immediately?',
options: [
'Click the provided link immediately',
'Reply with your password',
'Verify the message through the official website or app',
'Forward your account details',
],
correctAnswerIndex: 2,
explanation:
'Urgent threats are commonly used in phishing. Verify the account through an official channel instead of using the message link.',
),

QuizQuestion(
category: 'Phishing & Scams',
question:
'What is a safe way to check whether a suspicious website is legitimate?',
options: [
'Enter your password to test it',
'Verify the website address and use an official source',
'Trust the website because it has a logo',
'Share the website with friends first',
],
correctAnswerIndex: 1,
explanation:
'Checking the address and reaching the service through an official source helps reduce the risk of phishing.',
),

QuizQuestion(
category: 'Phishing & Scams',
question:
'You receive a message saying you won a prize you never entered for. What is the safest action?',
options: [
'Send your personal information',
'Pay a fee immediately',
'Treat it cautiously and verify the claim independently',
'Share your account password',
],
correctAnswerIndex: 2,
explanation:
'Unexpected prize messages can be scams. Verify the claim independently before providing information or making payments.',
),

// ==========================================================
// PASSWORD SECURITY
// ==========================================================

QuizQuestion(
category: 'Password Security',
question:
'Which password practice is the safest?',
options: [
'Use the same password everywhere',
'Use a strong and unique password for each important account',
'Use your name as your password',
'Share your password with friends',
],
correctAnswerIndex: 1,
explanation:
'Using strong and unique passwords reduces the risk of one compromised account affecting your other accounts.',
),

QuizQuestion(
category: 'Password Security',
question:
'Which password is generally stronger?',
options: [
'12345678',
'password123',
'A long unique password that is difficult to guess',
'Your first name and birth year',
],
correctAnswerIndex: 2,
explanation:
'Long, unique passwords are generally harder for attackers to guess or crack.',
),

QuizQuestion(
category: 'Password Security',
question:
'Why should you avoid using the same password for multiple accounts?',
options: [
'It makes accounts load slowly',
'One compromised password could expose multiple accounts',
'It prevents software updates',
'It makes your device use more storage',
],
correctAnswerIndex: 1,
explanation:
'Password reuse creates a risk because one stolen password may be used to access other accounts.',
),

QuizQuestion(
category: 'Password Security',
question:
'Where should you avoid storing passwords?',
options: [
'In a trusted password manager',
'In a secure protected system',
'In a public social media post',
'In a properly protected private location',
],
correctAnswerIndex: 2,
explanation:
'Passwords should never be publicly exposed because anyone could use them to access the account.',
),

QuizQuestion(
category: 'Password Security',
question:
'What should you do if you accidentally share your password with someone you do not trust?',
options: [
'Keep using the same password',
'Change the password promptly',
'Post the password publicly',
'Share another password with them',
],
correctAnswerIndex: 1,
explanation:
'A password that may have been exposed should be changed promptly to reduce the risk of unauthorized access.',
),

// ==========================================================
// PRIVACY
// ==========================================================

QuizQuestion(
category: 'Privacy',
question:
'What should you do before sharing personal information online?',
options: [
'Share it with everyone',
'Check who is requesting it and why',
'Post it publicly',
'Send it to unknown accounts',
],
correctAnswerIndex: 1,
explanation:
'Always consider who is requesting your information, why they need it, and whether the request is trustworthy.',
),

QuizQuestion(
category: 'Privacy',
question:
'What is the safest approach to privacy settings on social media?',
options: [
'Leave everything public',
'Review privacy settings and limit unnecessary information',
'Share your location with everyone',
'Post sensitive information publicly',
],
correctAnswerIndex: 1,
explanation:
'Reviewing privacy settings helps control who can access your information.',
),

QuizQuestion(
category: 'Privacy',
question:
'Which information should you avoid sharing publicly?',
options: [
'A general hobby',
'A favorite type of music',
'Sensitive personal or account information',
'A general interest',
],
correctAnswerIndex: 2,
explanation:
'Sensitive personal and account information can be misused if publicly exposed.',
),

QuizQuestion(
category: 'Privacy',
question:
'Why should you be careful when sharing your location online?',
options: [
'Location information can reveal where you are or have been',
'It increases internet speed',
'It improves password strength',
'It automatically removes malware',
],
correctAnswerIndex: 0,
explanation:
'Location information can reveal personal movement or whereabouts and should be shared carefully.',
),

// ==========================================================
// MOBILE SAFETY
// ==========================================================

QuizQuestion(
category: 'Mobile Safety',
question:
'What is a good way to protect your mobile device?',
options: [
'Install apps from unknown sources',
'Ignore software updates',
'Use a screen lock and keep the device updated',
'Disable all security features',
],
correctAnswerIndex: 2,
explanation:
'Screen locks and software updates help protect your device and reduce security risks.',
),

QuizQuestion(
category: 'Mobile Safety',
question:
'Why are software updates important for mobile devices?',
options: [
'They always delete personal files',
'They can include security fixes and improvements',
'They remove the need for passwords',
'They make every app public',
],
correctAnswerIndex: 1,
explanation:
'Software updates can fix known security weaknesses and improve device protection.',
),

QuizQuestion(
category: 'Mobile Safety',
question:
'What is safer when installing a mobile application?',
options: [
'Use a trusted official app store',
'Download every APK from random websites',
'Install unknown applications from messages',
'Disable device security checks',
],
correctAnswerIndex: 0,
explanation:
'Trusted official app stores provide a safer source for applications than random download locations.',
),

QuizQuestion(
category: 'Mobile Safety',
question:
'What should you do if an app requests permissions that seem unnecessary?',
options: [
'Allow every permission automatically',
'Review the permissions and consider whether they are necessary',
'Share your password with the app',
'Disable your device lock',
],
correctAnswerIndex: 1,
explanation:
'Reviewing permissions helps limit unnecessary access to device information and features.',
),

// ==========================================================
// SOCIAL MEDIA SAFETY
// ==========================================================

QuizQuestion(
category: 'Social Media Safety',
question:
'Someone you do not know sends you a suspicious message containing a link. What is the safest response?',
options: [
'Open the link',
'Share your personal information',
'Avoid the link and report or block the account if necessary',
'Send them your login details',
],
correctAnswerIndex: 2,
explanation:
'Unknown accounts may send phishing or malicious links. Avoid suspicious links and use platform reporting tools when appropriate.',
),

QuizQuestion(
category: 'Social Media Safety',
question:
'What should you do if an unknown social media account asks for your login details?',
options: [
'Send the details',
'Send only your password',
'Do not share them and report the suspicious request',
'Share them privately',
],
correctAnswerIndex: 2,
explanation:
'Login credentials are sensitive information and should not be shared with unknown accounts.',
),

QuizQuestion(
category: 'Social Media Safety',
question:
'What is a good practice when accepting social media friend requests?',
options: [
'Accept everyone',
'Accept requests only after considering whether you know or trust the person',
'Share your password first',
'Accept accounts with suspicious links',
],
correctAnswerIndex: 1,
explanation:
'Being selective about connections can reduce exposure to fake accounts and suspicious contacts.',
),

QuizQuestion(
category: 'Social Media Safety',
question:
'What should you do if someone posts your private information without permission?',
options: [
'Share more private information',
'Ignore every available safety option',
'Use the platform reporting and privacy controls and seek trusted help when needed',
'Give the person your password',
],
correctAnswerIndex: 2,
explanation:
'Platform reporting and privacy tools can help address inappropriate sharing of personal information.',
),

// ==========================================================
// ACCOUNT SECURITY
// ==========================================================

QuizQuestion(
category: 'Account Security',
question:
'What should you do if you suspect that your account has been compromised?',
options: [
'Ignore it',
'Share your password with someone online',
'Secure the account, change the password, and review account activity',
'Post your password publicly',
],
correctAnswerIndex: 2,
explanation:
'Secure the affected account promptly and review recent activity for anything unusual.',
),

QuizQuestion(
category: 'Account Security',
question:
'Why should you enable two-factor authentication when it is available?',
options: [
'It makes your password public',
'It adds an extra layer of account protection',
'It removes your account password',
'It allows anyone to access your account',
],
correctAnswerIndex: 1,
explanation:
'Two-factor authentication adds another verification step, making unauthorized access harder.',
),

QuizQuestion(
category: 'Account Security',
question:
'What should you do after receiving an unexpected login alert?',
options: [
'Ignore it completely',
'Review the account activity and secure the account if needed',
'Share your password with the sender',
'Post the alert publicly',
],
correctAnswerIndex: 1,
explanation:
'Unexpected login alerts should be reviewed so suspicious activity can be identified and addressed.',
),

QuizQuestion(
category: 'Account Security',
question:
'What should you do with an account recovery code?',
options: [
'Post it publicly',
'Share it with strangers',
'Keep it private and secure',
'Use it as your social media username',
],
correctAnswerIndex: 2,
explanation:
'Recovery codes can help access an account and should therefore be kept private and secure.',
),

// ==========================================================
// ONLINE FRAUD
// ==========================================================

QuizQuestion(
category: 'Online Fraud',
question:
'A website offers an unbelievable prize and asks for your personal information. What should you do?',
options: [
'Provide all requested information',
'Verify the offer through a trusted source before taking action',
'Share the offer immediately',
'Give them your account password',
],
correctAnswerIndex: 1,
explanation:
'Offers that seem too good to be true can be scams. Verify them independently before providing information.',
),

QuizQuestion(
category: 'Online Fraud',
question:
'Someone asks you to pay money urgently to receive an unexpected reward. What is safest?',
options: [
'Pay immediately',
'Send your banking password',
'Verify the offer independently before paying',
'Share your payment details publicly',
],
correctAnswerIndex: 2,
explanation:
'Unexpected urgent payment requests can be fraudulent. Verify the claim independently before sending money.',
),

QuizQuestion(
category: 'Online Fraud',
question:
'What is a warning sign of an online shopping scam?',
options: [
'A normal product description',
'A suspicious seller requesting unusual payment methods',
'A trusted payment process',
'A known store with clear contact information',
],
correctAnswerIndex: 1,
explanation:
'Unusual payment requests from suspicious sellers can be a warning sign of fraud.',
),

QuizQuestion(
category: 'Online Fraud',
question:
'Before making an online purchase from an unfamiliar seller, what should you do?',
options: [
'Send payment immediately',
'Research the seller and verify the website',
'Share your account password',
'Ignore reviews and warnings',
],
correctAnswerIndex: 1,
explanation:
'Checking the seller and website can help identify suspicious or fraudulent online stores.',
),

// ==========================================================
// MALWARE
// ==========================================================

QuizQuestion(
category: 'Malware',
question:
'What is malware?',
options: [
'A type of computer security threat',
'A normal photo file',
'A trusted password manager',
'A network cable',
],
correctAnswerIndex: 0,
explanation:
'Malware is malicious software designed to harm, disrupt, or gain unauthorized access to systems or data.',
),

QuizQuestion(
category: 'Malware',
question:
'Which action can reduce the risk of malware infection?',
options: [
'Download files from unknown sources',
'Open every suspicious attachment',
'Keep software updated and use trusted sources',
'Disable security features',
],
correctAnswerIndex: 2,
explanation:
'Keeping software updated and using trusted sources can reduce exposure to malicious software.',
),

QuizQuestion(
category: 'Malware',
question:
'Why should you be careful with unexpected email attachments?',
options: [
'They can contain malicious files',
'They always improve computer performance',
'They automatically strengthen passwords',
'They remove security warnings',
],
correctAnswerIndex: 0,
explanation:
'Unexpected attachments can contain malicious software, so they should be treated cautiously.',
),

QuizQuestion(
category: 'Malware',
question:
'What is a safer approach when downloading software?',
options: [
'Use trusted official sources',
'Download from random links',
'Install unknown cracked software',
'Disable security checks first',
],
correctAnswerIndex: 0,
explanation:
'Trusted official sources reduce the risk of downloading modified or malicious software.',
),

// ==========================================================
// ONLINE SAFETY
// ==========================================================

QuizQuestion(
category: 'Online Safety',
question:
'Why should you avoid using public Wi-Fi for sensitive activities when the network is untrusted?',
options: [
'Untrusted networks can create additional security risks',
'Public Wi-Fi always deletes files',
'It automatically changes your password',
'It prevents all websites from working',
],
correctAnswerIndex: 0,
explanation:
'Untrusted networks can introduce security risks, so sensitive activities should be handled carefully.',
),

QuizQuestion(
category: 'Online Safety',
question:
'What should you do when a website asks for sensitive information unexpectedly?',
options: [
'Provide everything immediately',
'Verify the website and reason for the request',
'Share your password with another user',
'Ignore all security indicators',
],
correctAnswerIndex: 1,
explanation:
'Unexpected requests for sensitive information should be verified before anything is submitted.',
),

QuizQuestion(
category: 'Online Safety',
question:
'What is a good general cyber-safety habit?',
options: [
'Trust every message',
'Click every link',
'Think before clicking and verify suspicious requests',
'Share passwords with friends',
],
correctAnswerIndex: 2,
explanation:
'Pausing before clicking and verifying suspicious requests can help prevent many common cyber threats.',
),

QuizQuestion(
category: 'Online Safety',
question:
'What should you do if you receive a suspicious message from an unknown sender?',
options: [
'Reply with personal information',
'Click every attachment',
'Avoid suspicious content and use reporting or blocking tools when appropriate',
'Send your account password',
],
correctAnswerIndex: 2,
explanation:
'Avoiding suspicious content and using available reporting or blocking tools can reduce risk.',
),

// ==========================================================
// DATA PROTECTION
// ==========================================================

QuizQuestion(
category: 'Data Protection',
question:
'Why is it important to back up important files?',
options: [
'Backups can help recover data after loss or damage',
'Backups make passwords unnecessary',
'Backups prevent every cyber attack',
'Backups make personal information public',
],
correctAnswerIndex: 0,
explanation:
'Backups provide another copy of important information that can help with recovery after data loss.',
),

QuizQuestion(
category: 'Data Protection',
question:
'Which information should receive extra protection?',
options: [
'Sensitive personal and account information',
'A public weather forecast',
'A general news headline',
'A public sports score',
],
correctAnswerIndex: 0,
explanation:
'Sensitive personal and account information can cause harm if exposed or misused, so it needs stronger protection.',
),

QuizQuestion(
category: 'Data Protection',
question:
'What is a good practice when sharing documents online?',
options: [
'Share them publicly by default',
'Check the recipient and access permissions before sharing',
'Include passwords inside public posts',
'Send documents to unknown accounts',
],
correctAnswerIndex: 1,
explanation:
'Checking recipients and access permissions helps prevent accidental exposure of private information.',
),
];
}
