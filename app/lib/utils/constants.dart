class AppConstants {
  // App Information
  static const String appName = 'JointSaathi';
  static const String appVersion = '1.0.0';
  
  // API Configuration (environment-switchable for emulator/device)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
  );
  // No longer need apiVersion separately since it's in baseUrl
  
  // Database
  static const String databaseName = 'joint_saathi.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String keyUserId = 'current_user_id';
  static const String keyLanguage = 'language';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyAutoSyncEnabled = 'auto_sync_enabled';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  
  // Risk Levels
  static const String riskLow = 'low';
  static const String riskMedium = 'medium';
  static const String riskHigh = 'high';
  
  // Genders
  static const String genderMale = 'male';
  static const String genderFemale = 'female';
  static const String genderOther = 'other';
  
  // Screening Parameters
  static const int maxPainLevel = 10;
  static const int gaitTestDurationSeconds = 30;
  
  // Sync
  static const int maxRetryCount = 3;
  static const Duration syncInterval = Duration(minutes: 15);
  
  // Categories
  static const String categoryExercises = 'exercises';
  static const String categoryDiet = 'diet';
  static const String categoryLifestyle = 'lifestyle';
}

class AppStrings {
  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorDatabase = 'Database error. Please try again.';
  static const String errorValidation = 'Please fill all required fields correctly.';
  static const String errorAuth = 'Authentication failed. Please check your credentials.';
  static const String errorPermission = 'Permission denied. Please grant required permissions.';
  
  // Success Messages
  static const String successSave = 'Saved successfully';
  static const String successDelete = 'Deleted successfully';
  static const String successSync = 'Synced successfully';
  static const String successScreening = 'Screening completed successfully';
  
  // Instructions
  static const String gaitTestInstructions = '''
1. Ask the patient to walk straight for 10 meters
2. Hold the phone steady while recording
3. Ensure the patient walks at their normal pace
4. The app will record accelerometer and gyroscope data
5. Wait for the recording to complete automatically
  ''';
  
  static const String symptomInstructions = '''
1. Ask the patient about their pain level (0-10)
2. Inquire about morning stiffness duration
3. Check for visible swelling in joints
4. Ask about any past injuries or surgeries
  ''';
}
