import 'package:flutter/material.dart';

import '../services/app_settings.dart';

class AppLocalizations {
final String language;

const AppLocalizations(this.language);

// ==========================================================
// GET CURRENT LOCALIZATION
// ==========================================================

static AppLocalizations of(BuildContext context) {
return AppLocalizations(
AppSettings.instance.language,
);
}

// ==========================================================
// HELPER
// ==========================================================

String _text({
required String english,
required String urdu,
required String romanUrdu,
}) {
switch (language) {
case 'اردو':
return urdu;

case 'Roman Urdu':
return romanUrdu;

case 'English':
default:
return english;
}
}

// ==========================================================
// GENERAL
// ==========================================================

String get appName => _text(
english: 'CyberSafe',
urdu: 'سائبر سیف',
romanUrdu: 'CyberSafe',
);

String get cyberCrimeProtection => _text(
english: 'Cyber Crime Protection',
urdu: 'سائبر کرائم سے تحفظ',
romanUrdu: 'Cyber Crime se Hifazat',
);

String get welcomeBack => _text(
english: 'Welcome back!',
urdu: 'خوش آمدید!',
romanUrdu: 'Khush Aamdeed!',
);

String get protected => _text(
english: 'Protected',
urdu: 'محفوظ',
romanUrdu: 'Mehfooz',
);

// ==========================================================
// QUICK ACTIONS
// ==========================================================

String get quickActions => _text(
english: 'Quick Actions',
urdu: 'فوری اقدامات',
romanUrdu: 'Fori Iqdamat',
);

String get report => _text(
english: 'Report',
urdu: 'رپورٹ',
romanUrdu: 'Report',
);

String get submitComplaint => _text(
english: 'Submit complaint',
urdu: 'شکایت جمع کریں',
romanUrdu: 'Shikayat Jama Karein',
);

String get track => _text(
english: 'Track',
urdu: 'ٹریک',
romanUrdu: 'Track',
);

String get checkStatus => _text(
english: 'Check status',
urdu: 'حیثیت چیک کریں',
romanUrdu: 'Status Check Karein',
);

String get awareness => _text(
english: 'Awareness',
urdu: 'آگاہی',
romanUrdu: 'Aagahi',
);

String get learnAndStaySafe => _text(
english: 'Learn & stay safe',
urdu: 'سیکھیں اور محفوظ رہیں',
romanUrdu: 'Seekhein aur Mehfooz Rahein',
);

String get aiAssistant => _text(
english: 'AI Assistant',
urdu: 'اے آئی معاون',
romanUrdu: 'AI Assistant',
);

String get getGuidance => _text(
english: 'Get guidance',
urdu: 'رہنمائی حاصل کریں',
romanUrdu: 'Rehnumai Hasil Karein',
);

// ==========================================================
// COMPLAINTS
// ==========================================================

String get myComplaints => _text(
english: 'My Complaints',
urdu: 'میری شکایات',
romanUrdu: 'Meri Shikayaat',
);

String get total => _text(
english: 'Total',
urdu: 'کل',
romanUrdu: 'Kul',
);

String get review => _text(
english: 'Review',
urdu: 'جائزہ',
romanUrdu: 'Jaeza',
);

String get progress => _text(
english: 'Progress',
urdu: 'پیش رفت',
romanUrdu: 'Peshraft',
);

String get resolved => _text(
english: 'Resolved',
urdu: 'حل شدہ',
romanUrdu: 'Hal Shuda',
);

String get pending => _text(
english: 'Pending',
urdu: 'زیر التوا',
romanUrdu: 'Pending',
);

String get underReview => _text(
english: 'Under Review',
urdu: 'جائزے کے تحت',
romanUrdu: 'Review ke Tehat',
);

String get submitted => _text(
english: 'Submitted',
urdu: 'جمع شدہ',
romanUrdu: 'Submitted',
);

String get rejected => _text(
english: 'Rejected',
urdu: 'مسترد شدہ',
romanUrdu: 'Mustarad Shuda',
);

// ==========================================================
// SAFETY
// ==========================================================

String get stayCyberSafe => _text(
english: 'Stay Cyber Safe',
urdu: 'سائبر دنیا میں محفوظ رہیں',
romanUrdu: 'Cyber Duniya Mein Mehfooz Rahein',
);

String get exploreSafetyTips => _text(
english:
'Explore simple safety tips to protect yourself online.',
urdu:
'آن لائن خود کو محفوظ رکھنے کے لیے آسان حفاظتی تجاویز دیکھیں۔',
romanUrdu:
'Online khud ko mehfooz rakhne ke liye aasaan safety tips dekhein.',
);

String get remember => _text(
english: 'Remember',
urdu: 'یاد رکھیں',
romanUrdu: 'Yaad Rakhein',
);

String get neverShareSensitiveInfo => _text(
english:
'Never share passwords, OTPs or sensitive account information with unknown people.',
urdu:
'پاس ورڈ، OTP یا اکاؤنٹ کی حساس معلومات کبھی بھی نامعلوم افراد کے ساتھ شیئر نہ کریں۔',
romanUrdu:
'Password, OTP ya account ki sensitive information kabhi unknown logon ke sath share na karein.',
);

// ==========================================================
// NAVIGATION
// ==========================================================

String get notifications => _text(
english: 'Notifications',
urdu: 'اطلاعات',
romanUrdu: 'Notifications',
);

String get settings => _text(
english: 'Settings',
urdu: 'ترتیبات',
romanUrdu: 'Settings',
);

String get profile => _text(
english: 'Profile',
urdu: 'پروفائل',
romanUrdu: 'Profile',
);

String get home => _text(
english: 'Home',
urdu: 'ہوم',
romanUrdu: 'Home',
);

String get admin => _text(
english: 'Admin',
urdu: 'ایڈمن',
romanUrdu: 'Admin',
);

// ==========================================================
// LANGUAGE
// ==========================================================

String get languageLabel => _text(
english: 'Language',
urdu: 'زبان',
romanUrdu: 'Zaban',
);

// These are language names, so they intentionally stay fixed.
String get english => 'English';

String get urdu => 'اردو';

String get romanUrdu => 'Roman Urdu';

// ==========================================================
// AUTH
// ==========================================================

String get login => _text(
english: 'Login',
urdu: 'لاگ اِن',
romanUrdu: 'Login',
);

String get logout => _text(
english: 'Logout',
urdu: 'لاگ آؤٹ',
romanUrdu: 'Logout',
);

String get signup => _text(
english: 'Sign Up',
urdu: 'سائن اپ',
romanUrdu: 'Sign Up',
);

String get register => _text(
english: 'Register',
urdu: 'رجسٹر کریں',
romanUrdu: 'Register Karein',
);

String get createAccount => _text(
english: 'Create Account',
urdu: 'اکاؤنٹ بنائیں',
romanUrdu: 'Account Banayein',
);

String get email => _text(
english: 'Email',
urdu: 'ای میل',
romanUrdu: 'Email',
);

String get password => _text(
english: 'Password',
urdu: 'پاس ورڈ',
romanUrdu: 'Password',
);

String get confirmPassword => _text(
english: 'Confirm Password',
urdu: 'پاس ورڈ کی تصدیق کریں',
romanUrdu: 'Password Confirm Karein',
);

String get forgotPassword => _text(
english: 'Forgot Password?',
urdu: 'پاس ورڈ بھول گئے؟',
romanUrdu: 'Password Bhool Gaye?',
);

String get continueText => _text(
english: 'Continue',
urdu: 'جاری رکھیں',
romanUrdu: 'Continue Karein',
);

// ==========================================================
// COMMON BUTTONS
// ==========================================================

String get save => _text(
english: 'Save',
urdu: 'محفوظ کریں',
romanUrdu: 'Save Karein',
);

String get cancel => _text(
english: 'Cancel',
urdu: 'منسوخ کریں',
romanUrdu: 'Cancel Karein',
);

String get ok => _text(
english: 'OK',
urdu: 'ٹھیک ہے',
romanUrdu: 'Theek Hai',
);

String get close => _text(
english: 'Close',
urdu: 'بند کریں',
romanUrdu: 'Close',
);

String get delete => _text(
english: 'Delete',
urdu: 'حذف کریں',
romanUrdu: 'Delete Karein',
);

String get edit => _text(
english: 'Edit',
urdu: 'ترمیم کریں',
romanUrdu: 'Edit Karein',
);

String get submit => _text(
english: 'Submit',
urdu: 'جمع کریں',
romanUrdu: 'Submit Karein',
);

String get next => _text(
english: 'Next',
urdu: 'اگلا',
romanUrdu: 'Agla',
);

String get previous => _text(
english: 'Previous',
urdu: 'پچھلا',
romanUrdu: 'Pichla',
);

String get retry => _text(
english: 'Retry',
urdu: 'دوبارہ کوشش کریں',
romanUrdu: 'Dobara Koshish Karein',
);

// ==========================================================
// COMPLAINT FORM
// ==========================================================

String get reportCyberCrime => _text(
english: 'Report Cyber Crime',
urdu: 'سائبر کرائم کی رپورٹ کریں',
romanUrdu: 'Cyber Crime Report Karein',
);

String get selectIncidentDate => _text(
english: 'Select incident date',
urdu: 'واقعے کی تاریخ منتخب کریں',
romanUrdu: 'Waqe ki tareekh select karein',
);

String get addEvidence => _text(
english: 'Add Evidence',
urdu: 'ثبوت شامل کریں',
romanUrdu: 'Saboot Shamil Karein',
);

String get attachEvidenceDescription => _text(
english: 'Attach screenshots, photos or documents.',
urdu: 'اسکرین شاٹس، تصاویر یا دستاویزات منسلک کریں۔',
romanUrdu: 'Screenshots, photos ya documents attach karein.',
);

String get takePhoto => _text(
english: 'Take Photo',
urdu: 'تصویر لیں',
romanUrdu: 'Photo Lein',
);

String get captureEvidenceWithCamera => _text(
english: 'Capture evidence with camera',
urdu: 'کیمرے سے ثبوت حاصل کریں',
romanUrdu: 'Camera se saboot hasil karein',
);

String get chooseFromGallery => _text(
english: 'Choose from Gallery',
urdu: 'گیلری سے منتخب کریں',
romanUrdu: 'Gallery se select karein',
);

String get selectImages => _text(
english: 'Select one or more images',
urdu: 'ایک یا زیادہ تصاویر منتخب کریں',
romanUrdu: 'Ek ya zyada images select karein',
);

String get chooseFile => _text(
english: 'Choose File',
urdu: 'فائل منتخب کریں',
romanUrdu: 'File select karein',
);

String get selectDocuments => _text(
english: 'Select PDF, Word, text or image file',
urdu: 'PDF، Word، ٹیکسٹ یا تصویر کی فائل منتخب کریں',
romanUrdu: 'PDF, Word, text ya image file select karein',
);

String get personalInformation => _text(
english: 'Personal Information',
urdu: 'ذاتی معلومات',
romanUrdu: 'Zati Maloomat',
);

String get provideContactInformation => _text(
english: 'Provide your contact information.',
urdu: 'اپنی رابطے کی معلومات فراہم کریں۔',
romanUrdu: 'Apni contact information dein.',
);

String get fullName => _text(
english: 'Full Name',
urdu: 'پورا نام',
romanUrdu: 'Poora Naam',
);

String get enterFullName => _text(
english: 'Enter your full name',
urdu: 'اپنا پورا نام درج کریں',
romanUrdu: 'Apna poora naam enter karein',
);

String get emailAddress => _text(
english: 'Email Address',
urdu: 'ای میل ایڈریس',
romanUrdu: 'Email Address',
);

String get enterYourEmail => _text(
english: 'Enter your email',
urdu: 'اپنی ای میل درج کریں',
romanUrdu: 'Apni email enter karein',
);

String get phoneNumber => _text(
english: 'Phone Number',
urdu: 'فون نمبر',
romanUrdu: 'Phone Number',
);

String get incidentInformation => _text(
english: 'Incident Information',
urdu: 'واقعے کی معلومات',
romanUrdu: 'Waqe ki Maloomat',
);

String get tellUsWhatHappened => _text(
english: 'Tell us what happened.',
urdu: 'ہمیں بتائیں کہ کیا ہوا۔',
romanUrdu: 'Humein batayein ke kya hua.',
);

String get complaintTitle => _text(
english: 'Complaint Title',
urdu: 'شکایت کا عنوان',
romanUrdu: 'Shikayat ka Unwan',
);

String get onlineShoppingFraud => _text(
english: 'e.g. Online Shopping Fraud',
urdu: 'مثلاً آن لائن شاپنگ فراڈ',
romanUrdu: 'Misal: Online Shopping Fraud',
);

String get complaintCategory => _text(
english: 'Complaint Category',
urdu: 'شکایت کی قسم',
romanUrdu: 'Shikayat ki Qism',
);

String get pleaseSelectCategory => _text(
english: 'Please select a category',
urdu: 'براہ کرم ایک قسم منتخب کریں',
romanUrdu: 'Barah-e-karam category select karein',
);

String get platform => _text(
english: 'Platform',
urdu: 'پلیٹ فارم',
romanUrdu: 'Platform',
);

String get platformHint => _text(
english: 'e.g. Instagram, WhatsApp, Facebook',
urdu: 'مثلاً انسٹاگرام، واٹس ایپ، فیس بک',
romanUrdu: 'Misal: Instagram, WhatsApp, Facebook',
);

String get incidentDate => _text(
english: 'Incident Date',
urdu: 'واقعے کی تاریخ',
romanUrdu: 'Waqe ki Tareekh',
);

String get location => _text(
english: 'Location',
urdu: 'مقام',
romanUrdu: 'Maqam',
);

String get cityArea => _text(
english: 'City / Area',
urdu: 'شہر / علاقہ',
romanUrdu: 'Shehar / Ilaqa',
);

String get suspectAccount => _text(
english: 'Suspect / Account',
urdu: 'مشتبہ شخص / اکاؤنٹ',
romanUrdu: 'Mushtaba Shakhs / Account',
);

String get suspectHint => _text(
english: 'Name, username or unknown',
urdu: 'نام، یوزرنیم یا نامعلوم',
romanUrdu: 'Naam, username ya unknown',
);

String get suspectContact => _text(
english: 'Suspect Contact',
urdu: 'مشتبہ شخص کا رابطہ',
romanUrdu: 'Mushtaba Shakhs ka Contact',
);

String get suspectContactHint => _text(
english: 'Phone / Email / Username',
urdu: 'فون / ای میل / یوزرنیم',
romanUrdu: 'Phone / Email / Username',
);

String get incidentDescription => _text(
english: 'Incident Description',
urdu: 'واقعے کی تفصیل',
romanUrdu: 'Waqe ki Tafseel',
);

String get describeIncidentClearly => _text(
english: 'Describe the incident clearly.',
urdu: 'واقعے کی واضح تفصیل بیان کریں۔',
romanUrdu: 'Waqe ki wazeh tafseel bayan karein.',
);

String get explainWhatHappened => _text(
english:
'Explain what happened, when it happened and any relevant details...',
urdu:
'بتائیں کہ کیا ہوا، کب ہوا اور اس سے متعلق کوئی اہم تفصیل...',
romanUrdu:
'Batayein ke kya hua, kab hua aur is se mutaliq koi aham tafseel...',
);

String get evidence => _text(
english: 'Evidence',
urdu: 'ثبوت',
romanUrdu: 'Saboot',
);

String get attachScreenshotsImagesDocuments => _text(
english: 'Attach screenshots, images or documents.',
urdu: 'اسکرین شاٹس، تصاویر یا دستاویزات منسلک کریں۔',
romanUrdu: 'Screenshots, images ya documents attach karein.',
);

String get cameraGalleryFile => _text(
english: 'Camera • Gallery • File',
urdu: 'کیمرہ • گیلری • فائل',
romanUrdu: 'Camera • Gallery • File',
);

String get reviewComplaint => _text(
english: 'Review Complaint',
urdu: 'شکایت کا جائزہ',
romanUrdu: 'Shikayat ka Jaeza',
);

String get reportSafely => _text(
english: 'Report Safely',
urdu: 'محفوظ طریقے سے رپورٹ کریں',
romanUrdu: 'Mehfooz Tareeqay se Report Karein',
);

String get provideAccurateInformation => _text(
english:
'Provide accurate information so your complaint can be reviewed properly.',
urdu:
'درست معلومات فراہم کریں تاکہ آپ کی شکایت کا مناسب طریقے سے جائزہ لیا جا سکے۔',
romanUrdu:
'Durust maloomat dein taake aapki shikayat ka munasib tareeqay se jaeza liya ja sake.',
);

String get confidentialInformation => _text(
english: 'Your information should be kept confidential.',
urdu: 'آپ کی معلومات کو خفیہ رکھا جائے گا۔',
romanUrdu: 'Aapki maloomat ko khufia rakha jayega.',
);

// ==========================================================
// EVIDENCE MESSAGES
// ==========================================================

String get evidenceAttachedSuccessfully => _text(
english: 'Evidence attached successfully.',
urdu: 'ثبوت کامیابی سے منسلک ہو گیا۔',
romanUrdu: 'Saboot kamyabi se attach ho gaya.',
);

String get evidenceAlreadyAttached => _text(
english: 'This file is already attached.',
urdu: 'یہ فائل پہلے ہی منسلک ہے۔',
romanUrdu: 'Yeh file pehle hi attach hai.',
);

String get maximumEvidenceFiles => _text(
english: 'Maximum 5 evidence files are allowed.',
urdu: 'زیادہ سے زیادہ 5 ثبوت فائلوں کی اجازت ہے۔',
romanUrdu: 'Zyada se zyada 5 evidence files ki ijazat hai.',
);

String get cameraCouldNotBeOpened => _text(
english:
'Camera could not be opened. Please check camera permission.',
urdu:
'کیمرہ نہیں کھل سکا۔ براہ کرم کیمرہ کی اجازت چیک کریں۔',
romanUrdu:
'Camera nahi khul saka. Camera permission check karein.',
);

String get galleryCouldNotBeOpened => _text(
english:
'Gallery could not be opened. Please try again.',
urdu:
'گیلری نہیں کھل سکی۔ براہ کرم دوبارہ کوشش کریں۔',
romanUrdu:
'Gallery nahi khul saki. Dobara koshish karein.',
);

String get unableToSelectFile => _text(
english:
'Unable to select file. Please try again.',
urdu:
'فائل منتخب نہیں ہو سکی۔ براہ کرم دوبارہ کوشش کریں۔',
romanUrdu:
'File select nahi ho saki. Dobara koshish karein.',
);

String get unableToReadSelectedImage => _text(
english:
'Unable to read selected image.',
urdu:
'منتخب کردہ تصویر پڑھی نہیں جا سکی۔',
romanUrdu:
'Selected image read nahi ho saki.',
);

// ==========================================================
// COMPLAINT VALIDATION
// ==========================================================

String get pleaseSelectComplaintCategory => _text(
english:
'Please select a complaint category.',
urdu:
'براہ کرم شکایت کی قسم منتخب کریں۔',
romanUrdu:
'Barah-e-karam complaint category select karein.',
);

String get pleaseSelectIncidentDate => _text(
english:
'Please select the incident date.',
urdu:
'براہ کرم واقعے کی تاریخ منتخب کریں۔',
romanUrdu:
'Barah-e-karam waqe ki tareekh select karein.',
);

String get incidentDateCannotBeFuture => _text(
english:
'Incident date cannot be in the future.',
urdu:
'واقعے کی تاریخ مستقبل کی نہیں ہو سکتی۔',
romanUrdu:
'Waqe ki tareekh future ki nahi ho sakti.',
);

String get nameRequired => _text(
english: 'Please enter your name.',
urdu: 'براہ کرم اپنا نام درج کریں۔',
romanUrdu: 'Barah-e-karam apna naam enter karein.',
);

String get nameTooShort => _text(
english: 'Name must contain at least 3 characters.',
urdu: 'نام کم از کم 3 حروف پر مشتمل ہونا چاہیے۔',
romanUrdu: 'Naam mein kam az kam 3 characters hone chahiye.',
);

String get emailRequired => _text(
english: 'Please enter your email.',
urdu: 'براہ کرم اپنی ای میل درج کریں۔',
romanUrdu: 'Barah-e-karam apni email enter karein.',
);

String get invalidEmail => _text(
english: 'Please enter a valid email address.',
urdu: 'براہ کرم درست ای میل ایڈریس درج کریں۔',
romanUrdu: 'Barah-e-karam valid email address enter karein.',
);

String get phoneRequired => _text(
english: 'Please enter your phone number.',
urdu: 'براہ کرم اپنا فون نمبر درج کریں۔',
romanUrdu: 'Barah-e-karam apna phone number enter karein.',
);

String get invalidPhone => _text(
english: 'Please enter a valid Pakistani phone number.',
urdu: 'براہ کرم درست پاکستانی فون نمبر درج کریں۔',
romanUrdu: 'Barah-e-karam valid Pakistani phone number enter karein.',
);

String get titleRequired => _text(
english: 'Please enter a complaint title.',
urdu: 'براہ کرم شکایت کا عنوان درج کریں۔',
romanUrdu: 'Barah-e-karam complaint title enter karein.',
);

String get titleTooShort => _text(
english: 'Complaint title must contain at least 5 characters.',
urdu: 'شکایت کا عنوان کم از کم 5 حروف پر مشتمل ہونا چاہیے۔',
romanUrdu: 'Complaint title mein kam az kam 5 characters hone chahiye.',
);

String get platformRequired => _text(
english: 'Please enter the platform.',
urdu: 'براہ کرم پلیٹ فارم درج کریں۔',
romanUrdu: 'Barah-e-karam platform enter karein.',
);

String get locationRequired => _text(
english: 'Please enter the location.',
urdu: 'براہ کرم مقام درج کریں۔',
romanUrdu: 'Barah-e-karam location enter karein.',
);

String get suspectRequired => _text(
english: 'Please enter the suspect or account.',
urdu: 'براہ کرم مشتبہ شخص یا اکاؤنٹ درج کریں۔',
romanUrdu: 'Barah-e-karam suspect ya account enter karein.',
);

String get descriptionRequired => _text(
english: 'Please describe the incident.',
urdu: 'براہ کرم واقعے کی تفصیل بیان کریں۔',
romanUrdu: 'Barah-e-karam waqe ki tafseel bayan karein.',
);

String get descriptionTooShort => _text(
english: 'Description must contain at least 20 characters.',
urdu: 'تفصیل کم از کم 20 حروف پر مشتمل ہونی چاہیے۔',
romanUrdu: 'Description mein kam az kam 20 characters hone chahiye.',
);

// ==========================================================
// FIREBASE / GENERAL ERRORS
// ==========================================================

String get firebasePermissionDenied => _text(
english:
'Permission denied. Please check your account permissions.',
urdu:
'اجازت مسترد کر دی گئی۔ براہ کرم اپنے اکاؤنٹ کی اجازتیں چیک کریں۔',
romanUrdu:
'Permission deny ho gayi. Apne account ki permissions check karein.',
);

String get firebaseTemporarilyUnavailable => _text(
english:
'The service is temporarily unavailable. Please try again.',
urdu:
'سروس عارضی طور پر دستیاب نہیں۔ براہ کرم دوبارہ کوشش کریں۔',
romanUrdu:
'Service temporarily available nahi hai. Dobara koshish karein.',
);

String get networkError => _text(
english:
'Network error. Please check your internet connection.',
urdu:
'نیٹ ورک کا مسئلہ ہے۔ براہ کرم اپنا انٹرنیٹ کنکشن چیک کریں۔',
romanUrdu:
'Network error hai. Internet connection check karein.',
);

String get sessionExpired => _text(
english:
'Your session has expired. Please log in again.',
urdu:
'آپ کا سیشن ختم ہو گیا ہے۔ براہ کرم دوبارہ لاگ اِن کریں۔',
romanUrdu:
'Aapka session expire ho gaya hai. Dobara login karein.',
);

String get unableToProcessRequest => _text(
english:
'Unable to process your request. Please try again.',
urdu:
'آپ کی درخواست مکمل نہیں ہو سکی۔ براہ کرم دوبارہ کوشش کریں۔',
romanUrdu:
'Aapki request process nahi ho saki. Dobara koshish karein.',
);

String get somethingWentWrong => _text(
english: 'Something went wrong. Please try again.',
urdu: 'کچھ غلط ہو گیا۔ براہ کرم دوبارہ کوشش کریں۔',
romanUrdu: 'Kuch ghalat ho gaya. Dobara koshish karein.',
);

// ==========================================================
// ADMIN SETTINGS
// ==========================================================

String get adminSettings => _text(
english: 'Admin Settings',
urdu: 'ایڈمن ترتیبات',
romanUrdu: 'Admin Settings',
);

String get general => _text(
english: 'General',
urdu: 'عمومی',
romanUrdu: 'General',
);

String get receiveAdminComplaintAlerts => _text(
english: 'Receive complaint alerts',
urdu: 'شکایات کی اطلاعات موصول کریں',
romanUrdu: 'Complaint alerts receive karein',
);

String get darkMode => _text(
english: 'Dark Mode',
urdu: 'ڈارک موڈ',
romanUrdu: 'Dark Mode',
);

String get useDarkAppearanceThroughoutApp => _text(
english:
'Use dark appearance throughout the app.',
urdu:
'پوری ایپ میں ڈارک انداز استعمال کریں۔',
romanUrdu:
'Poori app mein dark appearance use karein.',
);

String get administration => _text(
english: 'Administration',
urdu: 'انتظامیہ',
romanUrdu: 'Administration',
);

String get security => _text(
english: 'Security',
urdu: 'سیکیورٹی',
romanUrdu: 'Security',
);

String get manageAdministratorSecurity => _text(
english:
'Manage administrator security.',
urdu:
'ایڈمنسٹریٹر کی سیکیورٹی کا انتظام کریں۔',
romanUrdu:
'Administrator security manage karein.',
);

String get aboutCyberSafe => _text(
english: 'About CyberSafe',
urdu: 'سائبر سیف کے بارے میں',
romanUrdu: 'CyberSafe ke Baare Mein',
);

String get applicationInformation => _text(
english: 'Application Information',
urdu: 'ایپلیکیشن کی معلومات',
romanUrdu: 'Application Information',
);

String get account => _text(
english: 'Account',
urdu: 'اکاؤنٹ',
romanUrdu: 'Account',
);

String get signOutFromAdministratorAccount => _text(
english:
'Sign out from administrator account.',
urdu:
'ایڈمنسٹریٹر اکاؤنٹ سے سائن آؤٹ کریں۔',
romanUrdu:
'Administrator account se sign out karein.',
);

String get administrator => _text(
english: 'Administrator',
urdu: 'ایڈمنسٹریٹر',
romanUrdu: 'Administrator',
);

String get administratorSecurity => _text(
english: 'Administrator Security',
urdu: 'ایڈمنسٹریٹر سیکیورٹی',
romanUrdu: 'Administrator Security',
);

String get administratorSecurityMessage => _text(
english:
'Administrator access is protected by Firebase authentication and role-based security.',
urdu:
'ایڈمنسٹریٹر رسائی Firebase authentication اور role-based security سے محفوظ ہے۔',
romanUrdu:
'Administrator access Firebase authentication aur role-based security se mehfooz hai.',
);

String get aboutCyberSafeMessage => _text(
english:
'CyberSafe is a cyber crime complaint and awareness management system.',
urdu:
'CyberSafe سائبر کرائم شکایات اور آگاہی کا انتظامی نظام ہے۔',
romanUrdu:
'CyberSafe cyber crime complaints aur awareness management system hai.',
);

String get cybersafeAdminVersion => _text(
english: 'CyberSafe Admin • Version 1.0.0',
urdu: 'CyberSafe Admin • ورژن 1.0.0',
romanUrdu: 'CyberSafe Admin • Version 1.0.0',
);

String get administratorAccessDenied => _text(
english:
'Administrator access denied.',
urdu:
'ایڈمنسٹریٹر رسائی مسترد کر دی گئی۔',
romanUrdu:
'Administrator access deny ho gaya.',
);

String get administratorSessionNotFound => _text(
english:
'Administrator session was not found.',
urdu:
'ایڈمنسٹریٹر سیشن نہیں ملا۔',
romanUrdu:
'Administrator session nahi mila.',
);

String get unableToLoadAdminSettings => _text(
english:
'Unable to load administrator settings.',
urdu:
'ایڈمنسٹریٹر کی ترتیبات لوڈ نہیں ہو سکیں۔',
romanUrdu:
'Administrator settings load nahi ho sakin.',
);

String get notificationSettingsSaved => _text(
english:
'Notification settings saved.',
urdu:
'اطلاعات کی ترتیبات محفوظ ہو گئیں۔',
romanUrdu:
'Notification settings save ho gayi hain.',
);

String get unableToSaveNotificationSettings => _text(
english:
'Unable to save notification settings.',
urdu:
'اطلاعات کی ترتیبات محفوظ نہیں ہو سکیں۔',
romanUrdu:
'Notification settings save nahi ho sakin.',
);

String get darkModeEnabled => _text(
english:
'Dark mode enabled.',
urdu:
'ڈارک موڈ فعال کر دیا گیا۔',
romanUrdu:
'Dark mode enable ho gaya.',
);

String get darkModeDisabled => _text(
english:
'Dark mode disabled.',
urdu:
'ڈارک موڈ غیر فعال کر دیا گیا۔',
romanUrdu:
'Dark mode disable ho gaya.',
);

String get logoutConfirmationTitle => _text(
english:
'Logout',
urdu:
'لاگ آؤٹ',
romanUrdu:
'Logout',
);

String get logoutConfirmationMessage => _text(
english:
'Are you sure you want to logout?',
urdu:
'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟',
romanUrdu:
'Kya aap waqai logout karna chahte hain?',
);

String get logoutFailed => _text(
english:
'Logout failed. Please try again.',
urdu:
'لاگ آؤٹ ناکام ہو گیا۔ براہ کرم دوبارہ کوشش کریں۔',
romanUrdu:
'Logout fail ho gaya. Dobara koshish karein.',
);

// ==========================================================
// PROFILE
// ==========================================================

String get editProfile => _text(
english: 'Edit Profile',
urdu: 'پروفائل میں ترمیم کریں',
romanUrdu: 'Profile Edit Karein',
);

String get updateProfile => _text(
english: 'Update Profile',
urdu: 'پروفائل اپ ڈیٹ کریں',
romanUrdu: 'Profile Update Karein',
);

String get name => _text(
english: 'Name',
urdu: 'نام',
romanUrdu: 'Naam',
);

String get phone => _text(
english: 'Phone',
urdu: 'فون',
romanUrdu: 'Phone',
);

String get profileUpdated => _text(
english: 'Profile updated successfully.',
urdu: 'پروفائل کامیابی سے اپ ڈیٹ ہو گیا۔',
romanUrdu: 'Profile successfully update ho gaya.',
);

// ==========================================================
// NOTIFICATIONS
// ==========================================================

String get noNotifications => _text(
english: 'No notifications yet.',
urdu: 'ابھی کوئی اطلاعات نہیں ہیں۔',
romanUrdu: 'Abhi koi notifications nahi hain.',
);

String get markAllAsRead => _text(
english: 'Mark all as read',
urdu: 'سب کو پڑھا ہوا نشان زد کریں',
romanUrdu: 'Sab ko read mark karein',
);

String get notification => _text(
english: 'Notification',
urdu: 'اطلاع',
romanUrdu: 'Notification',
);

String get newComplaintSubmitted => _text(
english: 'New Complaint Submitted',
urdu: 'نئی شکایت جمع ہوئی',
romanUrdu: 'Nayi complaint submit hui',
);

String get complaintStatusUpdated => _text(
english: 'Complaint Status Updated',
urdu: 'شکایت کی حیثیت اپ ڈیٹ ہو گئی',
romanUrdu: 'Complaint status update ho gaya',
);

// ==========================================================
// AWARENESS
// ==========================================================

String get safetyTips => _text(
english: 'Safety Tips',
urdu: 'حفاظتی تجاویز',
romanUrdu: 'Safety Tips',
);

String get awarenessArticles => _text(
english: 'Awareness Articles',
urdu: 'آگاہی کے مضامین',
romanUrdu: 'Awareness Articles',
);

String get readMore => _text(
english: 'Read More',
urdu: 'مزید پڑھیں',
romanUrdu: 'Mazeed Parhein',
);

String get learnMore => _text(
english: 'Learn More',
urdu: 'مزید جانیں',
romanUrdu: 'Mazeed Jaanein',
);

String get cyberSafety => _text(
english: 'Cyber Safety',
urdu: 'سائبر سیفٹی',
romanUrdu: 'Cyber Safety',
);

// ==========================================================
// QUIZ
// ==========================================================

String get quiz => _text(
english: 'Cyber Safety Quiz',
urdu: 'سائبر سیفٹی کوئز',
romanUrdu: 'Cyber Safety Quiz',
);

String get startQuiz => _text(
english: 'Start Quiz',
urdu: 'کوئز شروع کریں',
romanUrdu: 'Quiz Shuru Karein',
);

String get submitQuiz => _text(
english: 'Submit Quiz',
urdu: 'کوئز جمع کریں',
romanUrdu: 'Quiz Submit Karein',
);

String get quizResult => _text(
english: 'Quiz Result',
urdu: 'کوئز کا نتیجہ',
romanUrdu: 'Quiz ka Nateeja',
);

String get score => _text(
english: 'Score',
urdu: 'اسکور',
romanUrdu: 'Score',
);

String get correctAnswers => _text(
english: 'Correct Answers',
urdu: 'درست جوابات',
romanUrdu: 'Durust Jawabat',
);

String get wrongAnswers => _text(
english: 'Wrong Answers',
urdu: 'غلط جوابات',
romanUrdu: 'Ghalat Jawabat',
);

String get tryAgain => _text(
english: 'Try Again',
urdu: 'دوبارہ کوشش کریں',
romanUrdu: 'Dobara Koshish Karein',
);

// ==========================================================
// DIALOGS
// ==========================================================

String get confirmation => _text(
english: 'Confirmation',
urdu: 'تصدیق',
romanUrdu: 'Tasdeeq',
);

String get areYouSure => _text(
english: 'Are you sure?',
urdu: 'کیا آپ کو یقین ہے؟',
romanUrdu: 'Kya aap ko yaqeen hai?',
);

String get changesSaved => _text(
english: 'Changes saved successfully.',
urdu: 'تبدیلیاں کامیابی سے محفوظ ہو گئیں۔',
romanUrdu: 'Changes successfully save ho gayi hain.',
);
}

