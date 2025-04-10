# Field Surveillance Robot Control App

A Flutter application for controlling a field surveillance robot with real-time video feed and sensor monitoring.

## Features

- Real-time camera feed with landscape orientation
- Directional controls (Forward, Backward, Left, Right, Stop)
- Crane control mechanism
- Real-time sensor monitoring
  - Temperature readings
  - Gas level detection
- Firebase integration for real-time data synchronization

## Requirements

- Flutter SDK
- Firebase account and configuration
- Android device with minimum SDK 21 (Android 5.0)
- Camera permissions
- Internet connectivity

## Setup

1. Clone the repository:
```bash
git clone https://github.com/Raghu1700/field_surveillance_robot.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add your `google-services.json` to `android/app/`
   - Update Firebase configuration in `lib/firebase_config.dart`

4. Run the app:
```bash
flutter run
```

## Usage

- The app runs in landscape mode for optimal viewing
- Camera feed takes up 2/3 of the screen
- Control panel on the right side includes:
  - Movement buttons
  - Crane toggle
  - Sensor readings display

## License

MIT License
