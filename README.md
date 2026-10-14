# Offline Ludo (Android / Flutter)

An original offline Ludo game prototype built with Flutter and null-safe Dart.

## Modes
- Play against a local computer opponent.
- Pass-and-play for up to four players on one device.
- No accounts, online multiplayer, ads, payments, or backend.

## Local development
Install the current stable Flutter SDK and Android SDK, then run:

```sh
flutter create --platforms=android --project-name=offline_ludo .
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

Build a debug APK with `flutter build apk --debug`.

See [developer handoff](docs/HANDOFF.md), [manual QA checklist](docs/QA_CHECKLIST.md), and [decisions](docs/DECISIONS.md).

> **Status: early MVP scaffold.** The game engine and first UI pass are present, but full board-path rendering, animated movement, comprehensive rule coverage, and real-device QA remain. Do not publish this prototype as a finished game.
