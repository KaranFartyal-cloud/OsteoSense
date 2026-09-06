// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'JointSaathi';

  @override
  String get appTagline => 'AI-Assisted OA Risk Screening';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_success => 'Success';

  @override
  String get common_retry => 'Retry';

  @override
  String get auth_welcome => 'Welcome to JointSaathi';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_signup => 'Sign Up';

  @override
  String get auth_logout => 'Logout';

  @override
  String get auth_workerId => 'Worker ID';

  @override
  String get auth_phone => 'Phone Number';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_otp => 'Enter OTP';

  @override
  String get auth_enterDetails => 'Enter your details to get started';

  @override
  String get auth_invalidPhone => 'Please enter a valid phone number';

  @override
  String get auth_loginSuccess => 'Logged in successfully';

  @override
  String get auth_signupSuccess => 'Account created successfully';

  @override
  String get home_title => 'Home';

  @override
  String home_welcome(Object name) {
    return 'Welcome back, $name';
  }

  @override
  String get home_totalPatients => 'Total Patients';

  @override
  String get home_totalScreenings => 'Total Screenings';

  @override
  String get home_highRisk => 'High Risk';

  @override
  String get home_pendingSync => 'Pending Sync';

  @override
  String get home_newScreening => 'New Screening';

  @override
  String get home_addPatient => 'Add Patient';

  @override
  String get home_recentPatients => 'Recent Patients';

  @override
  String get patients_title => 'Patients';

  @override
  String get patients_search => 'Search patients by name or village';

  @override
  String get patients_filterAll => 'All';

  @override
  String get patients_filterLowRisk => 'Low Risk';

  @override
  String get patients_filterMediumRisk => 'Medium Risk';

  @override
  String get patients_filterHighRisk => 'High Risk';

  @override
  String get patients_noPatients => 'No patients yet';

  @override
  String get patients_tapToAdd => 'Tap the + button to add your first patient';

  @override
  String get patients_addNew => 'Add Patient';

  @override
  String get patient_profile_title => 'Patient Profile';

  @override
  String get patient_information => 'Patient Information';

  @override
  String get patient_id => 'ID';

  @override
  String get patient_name => 'Name';

  @override
  String get patient_age => 'Age';

  @override
  String get patient_gender => 'Gender';

  @override
  String get patient_phone => 'Phone';

  @override
  String get patient_village => 'Village';

  @override
  String get patient_occupation => 'Occupation';

  @override
  String get patient_height => 'Height (cm)';

  @override
  String get patient_weight => 'Weight (kg)';

  @override
  String get patient_added => 'Added';

  @override
  String get patient_screeningHistory => 'Screening History';

  @override
  String get patient_noScreenings => 'No screenings yet';

  @override
  String get screening_title => 'Screening';

  @override
  String get screening_symptomQuestions => 'Symptom Questions';

  @override
  String get screening_gaitTest => 'Gait Test';

  @override
  String get screening_processing => 'Processing';

  @override
  String get screening_results => 'Results';

  @override
  String get screening_painLevel => 'Pain Level (0-10)';

  @override
  String get screening_stiffnessDuration => 'Stiffness Duration';

  @override
  String get screening_swelling => 'Swelling Present';

  @override
  String get screening_pastInjury => 'Past Joint Injury';

  @override
  String get screening_instructions => 'Instructions';

  @override
  String get screening_startTest => 'Start Test';

  @override
  String get screening_stopTest => 'Stop Test';

  @override
  String screening_testTime(Object time) {
    return 'Test Time: ${time}s';
  }

  @override
  String get screening_walking => 'Please walk naturally';

  @override
  String get screening_analyzing => 'Analyzing your data...';

  @override
  String screening_step(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get screening_analyzingSymptoms => 'Analyzing symptoms';

  @override
  String get screening_processingGait => 'Processing gait data';

  @override
  String get screening_calculatingRisk => 'Calculating risk';

  @override
  String get screening_generatingRecommendations =>
      'Generating recommendations';

  @override
  String get risk_title => 'Risk Assessment';

  @override
  String get risk_low => 'Low Risk';

  @override
  String get risk_medium => 'Medium Risk';

  @override
  String get risk_high => 'High Risk';

  @override
  String get risk_score => 'Risk Score';

  @override
  String get risk_confidence => 'Confidence';

  @override
  String get risk_contributing_factors => 'Contributing Factors';

  @override
  String get risk_aiReasoning => 'AI Reasoning';

  @override
  String get risk_recommendations => 'Recommendations';

  @override
  String get risk_viewReport => 'View Detailed Report';

  @override
  String get risk_share => 'Share';

  @override
  String get risk_backToHome => 'Back to Home';

  @override
  String get risk_lowDescription =>
      'Minimal OA risk. Routine checkup recommended.';

  @override
  String get risk_mediumDescription =>
      'Moderate risk. Specialist consultation recommended.';

  @override
  String get risk_highDescription =>
      'High OA risk. Urgent referral recommended.';

  @override
  String get reports_title => 'Analytics & Reports';

  @override
  String get reports_overview => 'Overview';

  @override
  String get reports_timeline => 'Timeline';

  @override
  String get reports_locations => 'Locations';

  @override
  String get reports_riskDistribution => 'Risk Distribution';

  @override
  String get reports_riskTrend => 'Risk Trend';

  @override
  String get reports_totalScreenings => 'Total Screenings';

  @override
  String get reports_avgConfidence => 'Avg Confidence';

  @override
  String get reports_noReports => 'No Reports Yet';

  @override
  String get reports_completeScreenings =>
      'Complete screenings to see analytics';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appSettings => 'App Settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_darkMode => 'Dark Mode';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_syncData => 'Sync & Data';

  @override
  String get settings_autoSync => 'Auto-Sync';

  @override
  String get settings_storageUsage => 'Storage Usage';

  @override
  String get settings_clearCache => 'Clear Cache';

  @override
  String get settings_about => 'About';

  @override
  String get settings_appVersion => 'App Version';

  @override
  String get settings_termsOfService => 'Terms of Service';

  @override
  String get settings_privacyPolicy => 'Privacy Policy';

  @override
  String get settings_dangerZone => 'Danger Zone';

  @override
  String get settings_logout => 'Logout';

  @override
  String get settings_selectLanguage => 'Select Language';

  @override
  String get settings_clearCacheConfirm => 'Clear Cache?';

  @override
  String get settings_clearCacheMessage =>
      'This will remove temporary files. Continue?';

  @override
  String get settings_cacheCleared => 'Cache cleared';

  @override
  String get settings_logoutConfirm => 'Logout?';

  @override
  String get settings_logoutMessage =>
      'You will be signed out of your account.';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_notLoggedIn => 'Not Logged In';

  @override
  String get profile_signIn => 'Sign In';

  @override
  String get profile_quickStats => 'Quick Stats';

  @override
  String get profile_about => 'About';

  @override
  String get profile_workerId => 'Worker ID';

  @override
  String get profile_active => 'Active';

  @override
  String get profile_screenings => 'Screenings';

  @override
  String get profile_patients => 'Patients';

  @override
  String get profile_avgConfidence => 'Avg Confidence';

  @override
  String get profile_downloadData => 'Download My Data';

  @override
  String get profile_preparing => 'Preparing download...';

  @override
  String get help_title => 'Help & FAQ';

  @override
  String get help_quickStart => 'Quick Start Guide';

  @override
  String get help_addPatients => 'Add patients';

  @override
  String get help_newScreening => 'New screening';

  @override
  String get help_gaitAnalysis => 'Gait analysis';

  @override
  String get help_viewResults => 'View results';

  @override
  String get help_faq => 'Frequently Asked Questions';

  @override
  String get help_stillNeed => 'Still Need Help?';

  @override
  String get help_contactSupport => 'Contact our support team for assistance';

  @override
  String get help_email => 'Email';

  @override
  String get help_phone => 'Phone';

  @override
  String get help_website => 'Website';

  @override
  String get sync_pending => 'Pending Sync';

  @override
  String get sync_syncing => 'Syncing...';

  @override
  String get sync_synced => 'Synced';

  @override
  String get sync_offline => 'Offline Mode';

  @override
  String get sync_retry => 'Retry Sync';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_invalidPhone => 'Invalid phone number';

  @override
  String get validation_passwordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get validation_passwordMismatch => 'Passwords do not match';

  @override
  String get months =>
      'January,February,March,April,May,June,July,August,September,October,November,December';

  @override
  String get daysOfWeek =>
      'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday';
}
