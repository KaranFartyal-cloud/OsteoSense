// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'JointSaathi';

  @override
  String get appTagline => 'AI-सहायक OA जोखिम स्क्रीनिंग';

  @override
  String get common_ok => 'ठीक है';

  @override
  String get common_cancel => 'रद्द करें';

  @override
  String get common_save => 'सहेजें';

  @override
  String get common_delete => 'हटाएं';

  @override
  String get common_edit => 'संपादित करें';

  @override
  String get common_back => 'वापस';

  @override
  String get common_next => 'आगे';

  @override
  String get common_skip => 'छोड़ें';

  @override
  String get common_loading => 'लोड हो रहा है...';

  @override
  String get common_error => 'त्रुटि';

  @override
  String get common_success => 'सफल';

  @override
  String get common_retry => 'पुनः प्रयास करें';

  @override
  String get auth_welcome => 'JointSaathi में आपका स्वागत है';

  @override
  String get auth_login => 'लॉगिन करें';

  @override
  String get auth_signup => 'साइन अप करें';

  @override
  String get auth_logout => 'लॉगआउट';

  @override
  String get auth_workerId => 'कर्मचारी ID';

  @override
  String get auth_phone => 'फोन नंबर';

  @override
  String get auth_password => 'पासवर्ड';

  @override
  String get auth_otp => 'OTP दर्ज करें';

  @override
  String get auth_enterDetails => 'शुरुआत करने के लिए अपना विवरण दर्ज करें';

  @override
  String get auth_invalidPhone => 'कृपया एक वैध फोन नंबर दर्ज करें';

  @override
  String get auth_loginSuccess => 'सफलतापूर्वक लॉगिन किया';

  @override
  String get auth_signupSuccess => 'खाता सफलतापूर्वक बनाया गया';

  @override
  String get home_title => 'होम';

  @override
  String home_welcome(Object name) {
    return 'स्वागत है, $name';
  }

  @override
  String get home_totalPatients => 'कुल रोगी';

  @override
  String get home_totalScreenings => 'कुल स्क्रीनिंग';

  @override
  String get home_highRisk => 'उच्च जोखिम';

  @override
  String get home_pendingSync => 'लंबित सिंक';

  @override
  String get home_newScreening => 'नई स्क्रीनिंग';

  @override
  String get home_addPatient => 'रोगी जोड़ें';

  @override
  String get home_recentPatients => 'हाल के रोगी';

  @override
  String get patients_title => 'रोगी';

  @override
  String get patients_search => 'रोगियों को नाम या गांव से खोजें';

  @override
  String get patients_filterAll => 'सभी';

  @override
  String get patients_filterLowRisk => 'कम जोखिम';

  @override
  String get patients_filterMediumRisk => 'मध्यम जोखिम';

  @override
  String get patients_filterHighRisk => 'उच्च जोखिम';

  @override
  String get patients_noPatients => 'अभी तक कोई रोगी नहीं';

  @override
  String get patients_tapToAdd => 'अपना पहला रोगी जोड़ने के लिए + बटन टैप करें';

  @override
  String get patients_addNew => 'रोगी जोड़ें';

  @override
  String get patient_profile_title => 'रोगी प्रोफ़ाइल';

  @override
  String get patient_information => 'रोगी की जानकारी';

  @override
  String get patient_id => 'ID';

  @override
  String get patient_name => 'नाम';

  @override
  String get patient_age => 'आयु';

  @override
  String get patient_gender => 'लिंग';

  @override
  String get patient_phone => 'फोन';

  @override
  String get patient_village => 'गांव';

  @override
  String get patient_occupation => 'व्यवसाय';

  @override
  String get patient_height => 'ऊंचाई (सेमी)';

  @override
  String get patient_weight => 'वजन (किग्रा)';

  @override
  String get patient_added => 'जोड़ा गया';

  @override
  String get patient_screeningHistory => 'स्क्रीनिंग इतिहास';

  @override
  String get patient_noScreenings => 'अभी तक कोई स्क्रीनिंग नहीं';

  @override
  String get screening_title => 'स्क्रीनिंग';

  @override
  String get screening_symptomQuestions => 'लक्षण प्रश्न';

  @override
  String get screening_gaitTest => 'चाल परीक्षण';

  @override
  String get screening_processing => 'प्रसंस्करण';

  @override
  String get screening_results => 'परिणाम';

  @override
  String get screening_painLevel => 'दर्द स्तर (0-10)';

  @override
  String get screening_stiffnessDuration => 'कठोरता की अवधि';

  @override
  String get screening_swelling => 'सूजन मौजूद है';

  @override
  String get screening_pastInjury => 'पिछली संयुक्त चोट';

  @override
  String get screening_instructions => 'निर्देश';

  @override
  String get screening_startTest => 'परीक्षण शुरू करें';

  @override
  String get screening_stopTest => 'परीक्षण बंद करें';

  @override
  String screening_testTime(Object time) {
    return 'परीक्षण समय: ${time}s';
  }

  @override
  String get screening_walking => 'कृपया स्वाभाविक रूप से चलें';

  @override
  String get screening_analyzing => 'आपके डेटा का विश्लेषण जारी है...';

  @override
  String screening_step(Object current, Object total) {
    return 'चरण $current का $total';
  }

  @override
  String get screening_analyzingSymptoms => 'लक्षणों का विश्लेषण';

  @override
  String get screening_processingGait => 'चाल डेटा का प्रसंस्करण';

  @override
  String get screening_calculatingRisk => 'जोखिम की गणना';

  @override
  String get screening_generatingRecommendations =>
      'सिफारिशें उत्पन्न की जा रही हैं';

  @override
  String get risk_title => 'जोखिम मूल्यांकन';

  @override
  String get risk_low => 'कम जोखिम';

  @override
  String get risk_medium => 'मध्यम जोखिम';

  @override
  String get risk_high => 'उच्च जोखिम';

  @override
  String get risk_score => 'जोखिम स्कोर';

  @override
  String get risk_confidence => 'आत्मविश्वास';

  @override
  String get risk_contributing_factors => 'योगदान कारक';

  @override
  String get risk_aiReasoning => 'AI तर्क';

  @override
  String get risk_recommendations => 'सिफारिशें';

  @override
  String get risk_viewReport => 'विस्तृत रिपोर्ट देखें';

  @override
  String get risk_share => 'साझा करें';

  @override
  String get risk_backToHome => 'होम पर वापस';

  @override
  String get risk_lowDescription =>
      'न्यूनतम OA जोखिम। नियमित जांच की सिफारिश की जाती है।';

  @override
  String get risk_mediumDescription =>
      'मध्यम जोखिम। विशेषज्ञ परामर्श की सिफारिश की जाती है।';

  @override
  String get risk_highDescription =>
      'उच्च OA जोखिम। तत्काल रेफरल की सिफारिश की जाती है।';

  @override
  String get reports_title => 'विश्लेषण और रिपोर्ट';

  @override
  String get reports_overview => 'अवलोकन';

  @override
  String get reports_timeline => 'समयरेखा';

  @override
  String get reports_locations => 'स्थान';

  @override
  String get reports_riskDistribution => 'जोखिम वितरण';

  @override
  String get reports_riskTrend => 'जोखिम प्रवृत्ति';

  @override
  String get reports_totalScreenings => 'कुल स्क्रीनिंग';

  @override
  String get reports_avgConfidence => 'औसत आत्मविश्वास';

  @override
  String get reports_noReports => 'कोई रिपोर्ट नहीं';

  @override
  String get reports_completeScreenings =>
      'विश्लेषण देखने के लिए स्क्रीनिंग पूरी करें';

  @override
  String get settings_title => 'सेटिंग्स';

  @override
  String get settings_appSettings => 'ऐप सेटिंग्स';

  @override
  String get settings_language => 'भाषा';

  @override
  String get settings_darkMode => 'डार्क मोड';

  @override
  String get settings_notifications => 'सूचनाएं';

  @override
  String get settings_syncData => 'डेटा सिंक करें';

  @override
  String get settings_autoSync => 'ऑटो-सिंक';

  @override
  String get settings_storageUsage => 'स्टोरेज उपयोग';

  @override
  String get settings_clearCache => 'कैश साफ़ करें';

  @override
  String get settings_about => 'बारे में';

  @override
  String get settings_appVersion => 'ऐप संस्करण';

  @override
  String get settings_termsOfService => 'सेवा की शर्तें';

  @override
  String get settings_privacyPolicy => 'गोपनीयता नीति';

  @override
  String get settings_dangerZone => 'खतरे का क्षेत्र';

  @override
  String get settings_logout => 'लॉगआउट';

  @override
  String get settings_selectLanguage => 'भाषा चुनें';

  @override
  String get settings_clearCacheConfirm => 'कैश साफ़ करें?';

  @override
  String get settings_clearCacheMessage =>
      'यह अस्थायी फ़ाइलों को हटा देगा। जारी रखें?';

  @override
  String get settings_cacheCleared => 'कैश साफ़ किया गया';

  @override
  String get settings_logoutConfirm => 'लॉगआउट?';

  @override
  String get settings_logoutMessage => 'आप अपने खाते से बाहर निकाल दिए जाएंगे।';

  @override
  String get profile_title => 'प्रोफ़ाइल';

  @override
  String get profile_notLoggedIn => 'लॉगिन नहीं किया गया';

  @override
  String get profile_signIn => 'साइन इन करें';

  @override
  String get profile_quickStats => 'त्वरित आंकड़े';

  @override
  String get profile_about => 'बारे में';

  @override
  String get profile_workerId => 'कर्मचारी ID';

  @override
  String get profile_active => 'सक्रिय';

  @override
  String get profile_screenings => 'स्क्रीनिंग';

  @override
  String get profile_patients => 'रोगी';

  @override
  String get profile_avgConfidence => 'औसत आत्मविश्वास';

  @override
  String get profile_downloadData => 'मेरा डेटा डाउनलोड करें';

  @override
  String get profile_preparing => 'डाउनलोड तैयार किया जा रहा है...';

  @override
  String get help_title => 'मदद और FAQ';

  @override
  String get help_quickStart => 'त्वरित शुरुआत गाइड';

  @override
  String get help_addPatients => 'रोगी जोड़ें';

  @override
  String get help_newScreening => 'नई स्क्रीनिंग';

  @override
  String get help_gaitAnalysis => 'चाल विश्लेषण';

  @override
  String get help_viewResults => 'परिणाम देखें';

  @override
  String get help_faq => 'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get help_stillNeed => 'अभी भी मदद चाहिए?';

  @override
  String get help_contactSupport =>
      'सहायता के लिए हमारी सहायता टीम से संपर्क करें';

  @override
  String get help_email => 'ईमेल';

  @override
  String get help_phone => 'फोन';

  @override
  String get help_website => 'वेबसाइट';

  @override
  String get sync_pending => 'लंबित सिंक';

  @override
  String get sync_syncing => 'सिंक हो रहा है...';

  @override
  String get sync_synced => 'सिंक किया गया';

  @override
  String get sync_offline => 'ऑफ़लाइन मोड';

  @override
  String get sync_retry => 'पुनः सिंक करने का प्रयास करें';

  @override
  String get validation_required => 'यह फ़ील्ड आवश्यक है';

  @override
  String get validation_invalidPhone => 'अमान्य फोन नंबर';

  @override
  String get validation_passwordTooShort =>
      'पासवर्ड कम से कम 6 वर्ण होना चाहिए';

  @override
  String get validation_passwordMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get months =>
      'जनवरी,फरवरी,मार्च,अप्रैल,मई,जून,जुलाई,अगस्त,सितंबर,अक्टूबर,नवंबर,दिसंबर';

  @override
  String get daysOfWeek =>
      'सोमवार,मंगलवार,बुधवार,गुरुवार,शुक्रवार,शनिवार,रविवार';
}
