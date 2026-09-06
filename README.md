# JointSaathi

AI-assisted osteoarthritis (OA) risk screening for healthcare workers in rural
and remote areas of India's North Eastern Region.

JointSaathi is designed as an offline-first, multilingual mobile app. It helps
healthcare workers record patient information, conduct symptom and gait
screenings, review AI-assisted risk assessments, and synchronize data when a
network connection is available.

> **Medical disclaimer:** JointSaathi is a screening and decision-support tool,
> not a diagnostic device. Clinical decisions must be made by qualified
> healthcare professionals.

## Highlights

- Offline-first patient and screening workflows
- On-device TFLite OA risk assessment
- Phone-sensor gait analysis using the accelerometer and gyroscope
- English and Hindi localization
- Risk results with confidence, contributing factors, and recommendations
- PDF report generation and sharing
- Local SQLite storage with online synchronization
- Healthcare worker authentication
- Optional BLE wearable integration groundwork

## Repository layout

```text
.
├── app/                  # Flutter mobile application
│   ├── lib/              # Dart source, screens, services, models, widgets
│   ├── assets/           # Images, icons, and TFLite model
│   ├── android/          # Android project
│   ├── ios/              # iOS project
│   ├── test/              # Flutter tests
│   └── pubspec.yaml
├── backend/              # Node.js API and data services
└── ai_service/           # Python AI microservice
```

## Technology

### Mobile app

- Flutter and Dart
- Provider and GoRouter
- SQLite (`sqflite`)
- Dio and `connectivity_plus`
- TensorFlow Lite (`tflite_flutter`)
- `sensors_plus` and `flutter_blue_plus`
- `fl_chart`, `pdf`, and `printing`
- Flutter localization and `intl`

### Backend services

- Node.js with Express
- MongoDB
- JWT authentication
- Python FastAPI AI service

## Requirements

- Flutter SDK 3.0 or newer
- Dart SDK 3.0 or newer
- Android Studio and Android SDK (API 21+)
- Xcode 14 or newer for iOS development
- Node.js 18 or newer for the backend
- Python 3.10 or newer for the AI service
- MongoDB for backend development

## Getting started

### 1. Clone the repository

```bash
git clone https://github.com/binoremohapatra/OsteoSense.git
cd OsteoSense
```

### 2. Run the Flutter app

```bash
cd app
flutter pub get
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

The app assets are already configured in `app/pubspec.yaml`. Place a compatible
model at `app/assets/models/oa_risk_model.tflite` when using a custom model.

### 3. Run the backend

Create `backend/.env` locally and configure the server, MongoDB, JWT secrets,
AI service URL, CORS origins, and rate limits. Do not commit this file or any
other environment file.

```bash
cd backend
npm install
npm start
```

### 4. Run the AI service

```bash
cd ai_service
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate
pip install -r requirements.txt
python main.py
```

## Main workflow

1. Select a language and complete onboarding.
2. Sign in or create a healthcare worker account.
3. Add or select a patient.
4. Complete the symptom questionnaire.
5. Run the guided gait test.
6. Review the AI-assisted risk result and recommendations.
7. Generate a report and sync data when online.

## Configuration

### Mobile app

- API configuration: `app/lib/utils/constants.dart`
- Localization files: `app/lib/l10n/`
- TFLite integration: `app/lib/services/tflite_service.dart`
- Android permissions: `app/android/app/src/main/AndroidManifest.xml`
- iOS permissions: `app/ios/Runner/Info.plist`

### Backend

The backend reads configuration from environment variables in `backend/.env`.
Use strong, unique JWT secrets outside local development. Never store secrets
in source control.

## Development commands

Run these from the relevant project directory:

```bash
# Flutter
cd app
flutter analyze
flutter test

# Backend
cd backend
npm test
```

## Localization

English and Hindi translations live in `app/lib/l10n/`. To add a language:

1. Add an ARB file such as `app/lib/l10n/app_as.arb`.
2. Follow the keys and metadata in `app_en.arb`.
3. Add the locale to the supported locales in `app/lib/main.dart`.
4. Regenerate Flutter localization output if required.

## Troubleshooting

### Flutter dependencies fail

Run `flutter clean`, then `flutter pub get` from `app/`.

### The TFLite model does not load

Confirm the model exists at `app/assets/models/oa_risk_model.tflite`, is
included in `app/pubspec.yaml`, and matches the input/output dimensions expected
by the TFLite service.

### Sensors do not work

Sensor and Bluetooth behavior may be limited on emulators. Test gait analysis
on a physical device and verify the required permissions.

### Backend synchronization fails

Check that MongoDB, the backend, and the AI service are running. Then verify
the API URL, CORS origins, authentication secrets, and network connectivity.

## Future improvements

- Regional NER languages such as Assamese and Bengali
- Wearable sensor integration
- Doctor and administrator portals
- Telemedicine consultation support
- Voice input and educational video content
- Medication reminders

## Contributing

1. Create a feature branch.
2. Make focused changes.
3. Run the relevant tests and analyzer.
4. Open a pull request with a clear description.

## License

This project is part of the MDoNER initiative for healthcare in North Eastern
India.

## Support

- Email: support@jointsaathi.com
- Helpline: 1800-XXX-XXXX
