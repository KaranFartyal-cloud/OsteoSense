# JointSaathi - AI-Assisted Osteoarthritis Risk Screening App

JointSaathi is an AI-assisted early detection app for Osteoarthritis (OA) risk screening, designed specifically for healthcare workers in rural and remote areas of the North Eastern Region (NER) of India. The app is offline-first, multilingual, and optimized for low-connectivity environments.

## Features

- **Offline-First Architecture**: Works completely without internet, syncs data when connection is available
- **AI-Powered Risk Assessment**: On-device TFLite model for OA risk classification
- **Gait Analysis**: Uses phone sensors (accelerometer, gyroscope) to analyze movement patterns
- **Multilingual Support**: English and Hindi with easy extensibility for regional NER languages
- **PDF Report Generation**: Generate and share professional screening reports
- **Patient Management**: Complete patient database with screening history
- **Healthcare Worker Authentication**: Secure login/signup for healthcare workers
- **Automatic Sync**: Queues offline data and syncs when internet is available
- **Clean UI**: Simple, accessible interface designed for rural healthcare workers

## Tech Stack

- **Framework**: Flutter (Dart) - Single codebase for iOS + Android
- **State Management**: Provider
- **Local Database**: SQLite (sqflite)
- **Network**: Dio
- **Connectivity**: connectivity_plus
- **AI/ML**: tflite_flutter
- **Sensors**: sensors_plus
- **BLE**: flutter_blue_plus (for future wearable integration)
- **Charts**: fl_chart
- **PDF**: pdf, printing
- **Localization**: flutter_localizations, intl
- **Notifications**: flutter_local_notifications

## Project Structure

```
app/
└── lib/
    ├── l10n/             # Localization files (English, Hindi)
    ├── models/           # Data models (Patient, Screening, User, etc.)
    ├── providers/        # State management providers
    ├── screens/          # UI screens
│   ├── auth/            # Authentication screens
│   ├── home/            # Home dashboard
│   ├── patients/        # Patient management
│   ├── screening/       # Screening flow
│   ├── results/         # Results and reports
│   ├── settings/        # Settings and utilities
│   ├── awareness/       # Preventive care content
│   └── analytics/       # Analytics dashboard
├── services/         # Business logic services
│   ├── database_helper.dart
│   ├── tflite_service.dart
│   ├── sensor_service.dart
│   ├── sync_service.dart
│   └── pdf_service.dart
├── utils/            # Utilities and constants
│   ├── app_theme.dart
│   ├── constants.dart
│   └── app_localizations.dart
└── widgets/          # Reusable widgets
```

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode
- For Android: Android SDK with API level 21+
- For iOS: Xcode 14+ with iOS 12+

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd OsteoSense\app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up assets**
   - Replace placeholder icons in `app/assets/icons/` with actual app icons
   - Add actual images to `app/assets/images/`
   - Place your trained TFLite model in `app/assets/models/oa_risk_model.tflite`

4. **Generate app icons and splash screen**
   ```bash
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash
   ```

5. **Run the app**
   ```bash
   # For Android
   cd app
   flutter run

   # For iOS
   cd app
   flutter run
   ```

## Configuration

### TFLite Model

The app uses a TFLite model for on-device AI risk classification. To use your own model:

1. Place your `.tflite` model file in `assets/models/oa_risk_model.tflite`
2. Update the model input/output dimensions in `lib/services/tflite_service.dart`
3. Ensure the model accepts the feature vector format provided by the service

### Backend API

The app is configured to sync with a backend when online. Update the API configuration:

- Edit `lib/utils/constants.dart` to set your `baseUrl`
- Configure authentication in `lib/services/sync_service.dart`

### Permissions

The app requires the following permissions:

**Android** (configured in `android/app/src/main/AndroidManifest.xml`):
- Internet and network state
- Body sensors (for gait analysis)
- Storage (for PDF reports)
- Bluetooth (for future wearable integration)
- Location (for Bluetooth scanning)
- Notifications

**iOS** (configured in `ios/Runner/Info.plist`):
- Motion sensors
- Bluetooth
- Location
- Photo library

## Usage

### For Healthcare Workers

1. **First-Time Setup**
   - Open the app and select your preferred language (English/Hindi)
   - Complete the onboarding slides
   - Sign up with your details (name, phone, health center ID, location)

2. **Adding Patients**
   - Navigate to the Patients tab
   - Tap the + button to add a new patient
   - Fill in patient details (name, age, gender, contact, village, occupation)

3. **Conducting Screening**
   - Go to the Screening tab
   - Select an existing patient or add a new one
   - Complete the symptom questionnaire:
     - Pain level (0-10)
     - Morning stiffness duration
     - Joint swelling (yes/no)
     - Past injury history
   - Perform gait test:
     - Follow on-screen instructions
     - Hold phone steady while patient walks
     - Recording stops automatically after 30 seconds
   - Review collected data
   - Submit for AI analysis

4. **Viewing Results**
   - Risk level displayed (Low/Medium/High) with color coding
   - Confidence percentage
   - Contributing factors identified by AI
   - Doctor recommendations based on risk level
   - Generate PDF report for sharing/printing

5. **Managing Data**
   - View all screenings in Reports tab
   - Filter patients by risk level
   - View patient profiles with screening history
   - Sync data when internet is available

### For Developers

**Adding New Languages**

1. Create a new ARB file in `app/lib/l10n/` (e.g., `app_as.arb` for Assamese)
2. Add translations following the format in `app_en.arb`
3. Update `app/lib/utils/app_localizations.dart` to include the new locale
4. Add the locale to the supported locales in `app/lib/main.dart`

**Extending the AI Model**

The TFLite service provides a fallback rule-based prediction when no model is available. To improve AI accuracy:

1. Train a model on OA screening data
2. Export to TFLite format
3. Update input preprocessing in `tflite_service.dart`
4. Test the model with sample data

**Adding New Screening Parameters**

1. Update the `Screening` model in `lib/models/screening.dart`
2. Add UI fields in `lib/screens/screening/symptom_questionnaire_screen.dart`
3. Update the feature vector in `lib/services/tflite_service.dart`
4. Modify the database schema if needed

## Offline Architecture

The app is designed to work completely offline:

1. **Local Storage**: All patient data and screenings saved in SQLite
2. **Sync Queue**: Changes queued when offline
3. **Auto-Sync**: Automatically syncs when internet becomes available
4. **Conflict Resolution**: Last-write-wins for now, can be enhanced

## Troubleshooting

**App crashes on startup**
- Ensure all dependencies are installed: `flutter pub get`
- Check that asset files exist in the specified paths
- Verify Android/iOS permissions are properly configured

**TFLite model not loading**
- Verify the model file exists in `assets/models/`
- Check that the model format is compatible with tflite_flutter
- Review model input/output dimensions in the service

**Sensors not working**
- Ensure sensor permissions are granted
- Check that the device has the required sensors
- Test on a physical device (sensors may not work on emulator)

**Sync not working**
- Verify backend API is accessible
- Check network connectivity
- Review sync service logs for errors

## Future Enhancements

- [ ] Add regional NER languages (Assamese, Bengali, etc.)
- [ ] Integrate wearable sensors via BLE
- [ ] Add analytics dashboard for administrators
- [ ] Implement telemedicine consultation features
- [ ] Add voice input for rural healthcare workers
- [ ] Create doctor portal for remote consultations
- [ ] Add medication reminders
- [ ] Implement video tutorials for exercises

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on both Android and iOS
5. Submit a pull request

## License

This project is part of the MDoNER initiative for healthcare in North Eastern India.

## Support

For support and queries:
- Email: support@jointsaathi.com
- Helpline: 1800-XXX-XXXX

## Team Credits

- **Development Team**: JointSaathi Development
- **AI/ML Team**: TFLite Model Development
- **Healthcare Advisors**: Medical Consultation
- **NER Healthcare Initiative**: MDoNER Support

## Acknowledgments

- Ministry of Development of North Eastern Region (MDoNER)
- Healthcare workers in rural NER for their valuable feedback
- Open-source Flutter community

---

**Version**: 1.0.0  
**Last Updated**: September 2024
#   O s t e o S e n s e  
 