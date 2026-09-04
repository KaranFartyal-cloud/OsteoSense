import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // English translations
  static const Map<String, String> _en = {
    'appName': 'JointSaathi',
    'welcome': 'Welcome',
    'selectLanguage': 'Select Language',
    'english': 'English',
    'hindi': 'Hindi',
    'continue': 'Continue',
    'login': 'Login',
    'signup': 'Sign Up',
    'logout': 'Logout',
    'phoneNumber': 'Phone Number',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'fullName': 'Full Name',
    'healthCenterId': 'Health Center ID',
    'location': 'Location',
    'village': 'Village',
    'occupation': 'Occupation',
    'age': 'Age',
    'gender': 'Gender',
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'contact': 'Contact',
    'address': 'Address',
    'home': 'Home',
    'patients': 'Patients',
    'screening': 'Screening',
    'reports': 'Reports',
    'settings': 'Settings',
    'newScreening': 'New Screening',
    'totalPatients': 'Total Patients',
    'pendingSync': 'Pending Sync',
    'recentScreenings': 'Recent Screenings',
    'syncNow': 'Sync Now',
    'syncStatus': 'Sync Status',
    'addPatient': 'Add Patient',
    'patientList': 'Patient List',
    'searchPatient': 'Search Patient',
    'patientProfile': 'Patient Profile',
    'screeningHistory': 'Screening History',
    'riskTrend': 'Risk Trend',
    'startScreening': 'Start Screening',
    'symptomQuestionnaire': 'Symptom Questionnaire',
    'gaitTest': 'Gait Test',
    'reviewConfirm': 'Review & Confirm',
    'processing': 'Processing...',
    'analyzing': 'Analyzing',
    'painLevel': 'Pain Level',
    'stiffnessDuration': 'Stiffness Duration',
    'swelling': 'Swelling',
    'pastInjury': 'Past Injury',
    'yes': 'Yes',
    'no': 'No',
    'instructions': 'Instructions',
    'startRecording': 'Start Recording',
    'stopRecording': 'Stop Recording',
    'recordingTime': 'Recording Time',
    'riskResult': 'Risk Result',
    'lowRisk': 'Low Risk',
    'mediumRisk': 'Medium Risk',
    'highRisk': 'High Risk',
    'confidence': 'Confidence',
    'contributingFactors': 'Contributing Factors',
    'detailedReport': 'Detailed Report',
    'doctorRecommendations': 'Doctor Recommendations',
    'generatePDF': 'Generate PDF',
    'share': 'Share',
    'download': 'Download',
    'print': 'Print',
    'preventiveCare': 'Preventive Care',
    'exercises': 'Exercises',
    'diet': 'Diet & Nutrition',
    'lifestyle': 'Lifestyle',
    'exerciseGuide': 'Exercise Guide',
    'dietTips': 'Diet Tips',
    'analytics': 'Analytics',
    'riskDistribution': 'Risk Distribution',
    'screeningsOverTime': 'Screenings Over Time',
    'locationReport': 'Location-wise Report',
    'highRiskCases': 'High Risk Cases',
    'language': 'Language',
    'offlineData': 'Offline Data',
    'notifications': 'Notifications',
    'profile': 'Profile',
    'editProfile': 'Edit Profile',
    'help': 'Help',
    'faq': 'FAQ',
    'about': 'About',
    'appPurpose': 'App Purpose',
    'teamCredits': 'Team Credits',
    'howToUse': 'How to Use',
    'commonQuestions': 'Common Questions',
    'submit': 'Submit',
    'cancel': 'Cancel',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'back': 'Back',
    'next': 'Next',
    'skip': 'Skip',
    'done': 'Done',
    'error': 'Error',
    'success': 'Success',
    'loading': 'Loading...',
    'noData': 'No Data Available',
    'networkError': 'Network Error',
    'tryAgain': 'Try Again',
    'invalidCredentials': 'Invalid credentials',
    'fillAllFields': 'Please fill all required fields',
    'passwordMismatch': 'Passwords do not match',
    'screeningComplete': 'Screening Complete',
    'screeningSaved': 'Screening saved successfully',
    'syncComplete': 'Sync Complete',
    'syncFailed': 'Sync Failed',
    'noInternet': 'No Internet Connection',
    'connected': 'Connected',
    'disconnected': 'Disconnected',
  };

  // Hindi translations
  static const Map<String, String> _hi = {
    'appName': 'जॉइंट साथी',
    'welcome': 'स्वागत है',
    'selectLanguage': 'भाषा चुनें',
    'english': 'अंग्रेजी',
    'hindi': 'हिंदी',
    'continue': 'जारी रखें',
    'login': 'लॉगिन',
    'signup': 'साइन अप',
    'logout': 'लॉग आउट',
    'phoneNumber': 'फ़ोन नंबर',
    'password': 'पासवर्ड',
    'confirmPassword': 'पासवर्ड की पुष्टि करें',
    'fullName': 'पूरा नाम',
    'healthCenterId': 'स्वास्थ्य केंद्र आईडी',
    'location': 'स्थान',
    'village': 'गांव',
    'occupation': 'व्यवसाय',
    'age': 'आयु',
    'gender': 'लिंग',
    'male': 'पुरुष',
    'female': 'महिला',
    'other': 'अन्य',
    'contact': 'संपर्क',
    'address': 'पता',
    'home': 'होम',
    'patients': 'रोगी',
    'screening': 'स्क्रीनिंग',
    'reports': 'रिपोर्ट',
    'settings': 'सेटिंग्स',
    'newScreening': 'नई स्क्रीनिंग',
    'totalPatients': 'कुल रोगी',
    'pendingSync': 'लंबित सिंक',
    'recentScreenings': 'हाल की स्क्रीनिंग',
    'syncNow': 'अभी सिंक करें',
    'syncStatus': 'सिंक स्थिति',
    'addPatient': 'रोगी जोड़ें',
    'patientList': 'रोगी सूची',
    'searchPatient': 'रोगी खोजें',
    'patientProfile': 'रोगी प्रोफ़ाइल',
    'screeningHistory': 'स्क्रीनिंग इतिहास',
    'riskTrend': 'रिस्क ट्रेंड',
    'startScreening': 'स्क्रीनिंग शुरू करें',
    'symptomQuestionnaire': 'लक्षण प्रश्नावली',
    'gaitTest': 'चाल परीक्षण',
    'reviewConfirm': 'समीक्षा और पुष्टि',
    'processing': 'प्रसंस्करण...',
    'analyzing': 'विश्लेषण',
    'painLevel': 'दर्द का स्तर',
    'stiffnessDuration': 'कठोरता अवधि',
    'swelling': 'सूजन',
    'pastInjury': 'पिछली चोट',
    'yes': 'हाँ',
    'no': 'नहीं',
    'instructions': 'निर्देश',
    'startRecording': 'रिकॉर्डिंग शुरू करें',
    'stopRecording': 'रिकॉर्डिंग रोकें',
    'recordingTime': 'रिकॉर्डिंग समय',
    'riskResult': 'जोखिम परिणाम',
    'lowRisk': 'कम जोखिम',
    'mediumRisk': 'मध्यम जोखिम',
    'highRisk': 'उच्च जोखिम',
    'confidence': 'विश्वास',
    'contributingFactors': 'योगदान कारक',
    'detailedReport': 'विस्तृत रिपोर्ट',
    'doctorRecommendations': 'डॉक्टर की सिफारिशें',
    'generatePDF': 'PDF बनाएं',
    'share': 'साझा करें',
    'download': 'डाउनलोड',
    'print': 'प्रिंट',
    'preventiveCare': 'रोकथाम देखभाल',
    'exercises': 'व्यायाम',
    'diet': 'आहार और पोषण',
    'lifestyle': 'जीवनशैली',
    'exerciseGuide': 'व्यायाम गाइड',
    'dietTips': 'आहार युक्तियाँ',
    'analytics': 'विश्लेषिकी',
    'riskDistribution': 'जोखिम वितरण',
    'screeningsOverTime': 'समय के साथ स्क्रीनिंग',
    'locationReport': 'स्थान-वार रिपोर्ट',
    'highRiskCases': 'उच्च जोखिम मामले',
    'language': 'भाषा',
    'offlineData': 'ऑफ़लाइन डेटा',
    'notifications': 'सूचनाएं',
    'profile': 'प्रोफ़ाइल',
    'editProfile': 'प्रोफ़ाइल संपादित करें',
    'help': 'मदद',
    'faq': 'सामान्य प्रश्न',
    'about': 'के बारे में',
    'appPurpose': 'ऐप उद्देश्य',
    'teamCredits': 'टीम क्रेडिट',
    'howToUse': 'उपयोग कैसे करें',
    'commonQuestions': 'सामान्य प्रश्न',
    'submit': 'जमा करें',
    'cancel': 'रद्द करें',
    'save': 'सहेजें',
    'delete': 'हटाएं',
    'edit': 'संपादित करें',
    'back': 'वापस',
    'next': 'अगला',
    'skip': 'छोड़ें',
    'done': 'हो गया',
    'error': 'त्रुटि',
    'success': 'सफलता',
    'loading': 'लोड हो रहा है...',
    'noData': 'कोई डेटा उपलब्ध नहीं',
    'networkError': 'नेटवर्क त्रुटि',
    'tryAgain': 'पुनः प्रयास करें',
    'invalidCredentials': 'अमान्य क्रेडेंशियल',
    'fillAllFields': 'कृपया सभी आवश्यक फ़ील्ड भरें',
    'passwordMismatch': 'पासवर्ड मेल नहीं खाते',
    'screeningComplete': 'स्क्रीनिंग पूर्ण',
    'screeningSaved': 'स्क्रीनिंग सफलतापूर्वक सहेजी गई',
    'syncComplete': 'सिंक पूर्ण',
    'syncFailed': 'सिंक विफल',
    'noInternet': 'इंटरनेट कनेक्शन नहीं',
    'connected': 'कनेक्टेड',
    'disconnected': 'डिस्कनेक्टेड',
  };

  final Locale locale;

  AppLocalizations(this.locale);

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'hi':
        return _hi;
      default:
        return _en;
    }
  }

  String get(String key) {
    return _strings[key] ?? key;
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat.jm(locale.languageCode).format(date);
  }

  String formatDateTime(DateTime date) {
    return DateFormat.yMMMd(locale.languageCode).add_jm().format(date);
  }

  String formatNumber(int number) {
    return NumberFormat.decimalPattern(locale.languageCode).format(number);
  }

  String formatPercentage(double value) {
    return NumberFormat.percentPattern(locale.languageCode).format(value / 100);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
