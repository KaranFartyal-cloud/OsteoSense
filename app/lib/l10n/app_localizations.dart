import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'JointSaathi'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'AI-Assisted OA Risk Screening'**
  String get appTagline;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @auth_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to JointSaathi'**
  String get auth_welcome;

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_signup;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @auth_workerId.
  ///
  /// In en, this message translates to:
  /// **'Worker ID'**
  String get auth_workerId;

  /// No description provided for @auth_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phone;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get auth_otp;

  /// No description provided for @auth_enterDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to get started'**
  String get auth_enterDetails;

  /// No description provided for @auth_invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get auth_invalidPhone;

  /// No description provided for @auth_loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get auth_loginSuccess;

  /// No description provided for @auth_signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get auth_signupSuccess;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_title;

  /// No description provided for @home_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {name}'**
  String home_welcome(Object name);

  /// No description provided for @home_totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get home_totalPatients;

  /// No description provided for @home_totalScreenings.
  ///
  /// In en, this message translates to:
  /// **'Total Screenings'**
  String get home_totalScreenings;

  /// No description provided for @home_highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get home_highRisk;

  /// No description provided for @home_pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Pending Sync'**
  String get home_pendingSync;

  /// No description provided for @home_newScreening.
  ///
  /// In en, this message translates to:
  /// **'New Screening'**
  String get home_newScreening;

  /// No description provided for @home_addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get home_addPatient;

  /// No description provided for @home_recentPatients.
  ///
  /// In en, this message translates to:
  /// **'Recent Patients'**
  String get home_recentPatients;

  /// No description provided for @patients_title.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients_title;

  /// No description provided for @patients_search.
  ///
  /// In en, this message translates to:
  /// **'Search patients by name or village'**
  String get patients_search;

  /// No description provided for @patients_filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get patients_filterAll;

  /// No description provided for @patients_filterLowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get patients_filterLowRisk;

  /// No description provided for @patients_filterMediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get patients_filterMediumRisk;

  /// No description provided for @patients_filterHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get patients_filterHighRisk;

  /// No description provided for @patients_noPatients.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get patients_noPatients;

  /// No description provided for @patients_tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first patient'**
  String get patients_tapToAdd;

  /// No description provided for @patients_addNew.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get patients_addNew;

  /// No description provided for @patient_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Patient Profile'**
  String get patient_profile_title;

  /// No description provided for @patient_information.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patient_information;

  /// No description provided for @patient_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get patient_id;

  /// No description provided for @patient_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get patient_name;

  /// No description provided for @patient_age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get patient_age;

  /// No description provided for @patient_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get patient_gender;

  /// No description provided for @patient_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get patient_phone;

  /// No description provided for @patient_village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get patient_village;

  /// No description provided for @patient_occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get patient_occupation;

  /// No description provided for @patient_height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get patient_height;

  /// No description provided for @patient_weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get patient_weight;

  /// No description provided for @patient_added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get patient_added;

  /// No description provided for @patient_screeningHistory.
  ///
  /// In en, this message translates to:
  /// **'Screening History'**
  String get patient_screeningHistory;

  /// No description provided for @patient_noScreenings.
  ///
  /// In en, this message translates to:
  /// **'No screenings yet'**
  String get patient_noScreenings;

  /// No description provided for @screening_title.
  ///
  /// In en, this message translates to:
  /// **'Screening'**
  String get screening_title;

  /// No description provided for @screening_symptomQuestions.
  ///
  /// In en, this message translates to:
  /// **'Symptom Questions'**
  String get screening_symptomQuestions;

  /// No description provided for @screening_gaitTest.
  ///
  /// In en, this message translates to:
  /// **'Gait Test'**
  String get screening_gaitTest;

  /// No description provided for @screening_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get screening_processing;

  /// No description provided for @screening_results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get screening_results;

  /// No description provided for @screening_painLevel.
  ///
  /// In en, this message translates to:
  /// **'Pain Level (0-10)'**
  String get screening_painLevel;

  /// No description provided for @screening_stiffnessDuration.
  ///
  /// In en, this message translates to:
  /// **'Stiffness Duration'**
  String get screening_stiffnessDuration;

  /// No description provided for @screening_swelling.
  ///
  /// In en, this message translates to:
  /// **'Swelling Present'**
  String get screening_swelling;

  /// No description provided for @screening_pastInjury.
  ///
  /// In en, this message translates to:
  /// **'Past Joint Injury'**
  String get screening_pastInjury;

  /// No description provided for @screening_instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get screening_instructions;

  /// No description provided for @screening_startTest.
  ///
  /// In en, this message translates to:
  /// **'Start Test'**
  String get screening_startTest;

  /// No description provided for @screening_stopTest.
  ///
  /// In en, this message translates to:
  /// **'Stop Test'**
  String get screening_stopTest;

  /// No description provided for @screening_testTime.
  ///
  /// In en, this message translates to:
  /// **'Test Time: {time}s'**
  String screening_testTime(Object time);

  /// No description provided for @screening_walking.
  ///
  /// In en, this message translates to:
  /// **'Please walk naturally'**
  String get screening_walking;

  /// No description provided for @screening_analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your data...'**
  String get screening_analyzing;

  /// No description provided for @screening_step.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String screening_step(Object current, Object total);

  /// No description provided for @screening_analyzingSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Analyzing symptoms'**
  String get screening_analyzingSymptoms;

  /// No description provided for @screening_processingGait.
  ///
  /// In en, this message translates to:
  /// **'Processing gait data'**
  String get screening_processingGait;

  /// No description provided for @screening_calculatingRisk.
  ///
  /// In en, this message translates to:
  /// **'Calculating risk'**
  String get screening_calculatingRisk;

  /// No description provided for @screening_generatingRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Generating recommendations'**
  String get screening_generatingRecommendations;

  /// No description provided for @risk_title.
  ///
  /// In en, this message translates to:
  /// **'Risk Assessment'**
  String get risk_title;

  /// No description provided for @risk_low.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get risk_low;

  /// No description provided for @risk_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get risk_medium;

  /// No description provided for @risk_high.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get risk_high;

  /// No description provided for @risk_score.
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get risk_score;

  /// No description provided for @risk_confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get risk_confidence;

  /// No description provided for @risk_contributing_factors.
  ///
  /// In en, this message translates to:
  /// **'Contributing Factors'**
  String get risk_contributing_factors;

  /// No description provided for @risk_aiReasoning.
  ///
  /// In en, this message translates to:
  /// **'AI Reasoning'**
  String get risk_aiReasoning;

  /// No description provided for @risk_recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get risk_recommendations;

  /// No description provided for @risk_viewReport.
  ///
  /// In en, this message translates to:
  /// **'View Detailed Report'**
  String get risk_viewReport;

  /// No description provided for @risk_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get risk_share;

  /// No description provided for @risk_backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get risk_backToHome;

  /// No description provided for @risk_lowDescription.
  ///
  /// In en, this message translates to:
  /// **'Minimal OA risk. Routine checkup recommended.'**
  String get risk_lowDescription;

  /// No description provided for @risk_mediumDescription.
  ///
  /// In en, this message translates to:
  /// **'Moderate risk. Specialist consultation recommended.'**
  String get risk_mediumDescription;

  /// No description provided for @risk_highDescription.
  ///
  /// In en, this message translates to:
  /// **'High OA risk. Urgent referral recommended.'**
  String get risk_highDescription;

  /// No description provided for @reports_title.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get reports_title;

  /// No description provided for @reports_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get reports_overview;

  /// No description provided for @reports_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get reports_timeline;

  /// No description provided for @reports_locations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get reports_locations;

  /// No description provided for @reports_riskDistribution.
  ///
  /// In en, this message translates to:
  /// **'Risk Distribution'**
  String get reports_riskDistribution;

  /// No description provided for @reports_riskTrend.
  ///
  /// In en, this message translates to:
  /// **'Risk Trend'**
  String get reports_riskTrend;

  /// No description provided for @reports_totalScreenings.
  ///
  /// In en, this message translates to:
  /// **'Total Screenings'**
  String get reports_totalScreenings;

  /// No description provided for @reports_avgConfidence.
  ///
  /// In en, this message translates to:
  /// **'Avg Confidence'**
  String get reports_avgConfidence;

  /// No description provided for @reports_noReports.
  ///
  /// In en, this message translates to:
  /// **'No Reports Yet'**
  String get reports_noReports;

  /// No description provided for @reports_completeScreenings.
  ///
  /// In en, this message translates to:
  /// **'Complete screenings to see analytics'**
  String get reports_completeScreenings;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settings_appSettings;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_darkMode;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync & Data'**
  String get settings_syncData;

  /// No description provided for @settings_autoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto-Sync'**
  String get settings_autoSync;

  /// No description provided for @settings_storageUsage.
  ///
  /// In en, this message translates to:
  /// **'Storage Usage'**
  String get settings_storageUsage;

  /// No description provided for @settings_clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settings_clearCache;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settings_appVersion;

  /// No description provided for @settings_termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_termsOfService;

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settings_dangerZone;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settings_logout;

  /// No description provided for @settings_selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settings_selectLanguage;

  /// No description provided for @settings_clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache?'**
  String get settings_clearCacheConfirm;

  /// No description provided for @settings_clearCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove temporary files. Continue?'**
  String get settings_clearCacheMessage;

  /// No description provided for @settings_cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get settings_cacheCleared;

  /// No description provided for @settings_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get settings_logoutConfirm;

  /// No description provided for @settings_logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out of your account.'**
  String get settings_logoutMessage;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get profile_notLoggedIn;

  /// No description provided for @profile_signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get profile_signIn;

  /// No description provided for @profile_quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get profile_quickStats;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profile_about;

  /// No description provided for @profile_workerId.
  ///
  /// In en, this message translates to:
  /// **'Worker ID'**
  String get profile_workerId;

  /// No description provided for @profile_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profile_active;

  /// No description provided for @profile_screenings.
  ///
  /// In en, this message translates to:
  /// **'Screenings'**
  String get profile_screenings;

  /// No description provided for @profile_patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get profile_patients;

  /// No description provided for @profile_avgConfidence.
  ///
  /// In en, this message translates to:
  /// **'Avg Confidence'**
  String get profile_avgConfidence;

  /// No description provided for @profile_downloadData.
  ///
  /// In en, this message translates to:
  /// **'Download My Data'**
  String get profile_downloadData;

  /// No description provided for @profile_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing download...'**
  String get profile_preparing;

  /// No description provided for @help_title.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get help_title;

  /// No description provided for @help_quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start Guide'**
  String get help_quickStart;

  /// No description provided for @help_addPatients.
  ///
  /// In en, this message translates to:
  /// **'Add patients'**
  String get help_addPatients;

  /// No description provided for @help_newScreening.
  ///
  /// In en, this message translates to:
  /// **'New screening'**
  String get help_newScreening;

  /// No description provided for @help_gaitAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Gait analysis'**
  String get help_gaitAnalysis;

  /// No description provided for @help_viewResults.
  ///
  /// In en, this message translates to:
  /// **'View results'**
  String get help_viewResults;

  /// No description provided for @help_faq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get help_faq;

  /// No description provided for @help_stillNeed.
  ///
  /// In en, this message translates to:
  /// **'Still Need Help?'**
  String get help_stillNeed;

  /// No description provided for @help_contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact our support team for assistance'**
  String get help_contactSupport;

  /// No description provided for @help_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get help_email;

  /// No description provided for @help_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get help_phone;

  /// No description provided for @help_website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get help_website;

  /// No description provided for @sync_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending Sync'**
  String get sync_pending;

  /// No description provided for @sync_syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get sync_syncing;

  /// No description provided for @sync_synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get sync_synced;

  /// No description provided for @sync_offline.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get sync_offline;

  /// No description provided for @sync_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry Sync'**
  String get sync_retry;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_required;

  /// No description provided for @validation_invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get validation_invalidPhone;

  /// No description provided for @validation_passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validation_passwordTooShort;

  /// No description provided for @validation_passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validation_passwordMismatch;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'January,February,March,April,May,June,July,August,September,October,November,December'**
  String get months;

  /// No description provided for @daysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday'**
  String get daysOfWeek;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
