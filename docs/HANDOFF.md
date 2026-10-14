# Handoff

## Local run
1. Install the current stable Flutter SDK and Android SDK.
2. Clone this repository and switch to `feat/ludo-mvp`.
3. Run `flutter pub get`, `flutter analyze`, and `flutter test`.
4. Run `flutter run` with an Android emulator or connected phone.
5. Build a test APK with `flutter build apk --debug`.

## Release preparation
- Replace `com.example.ludo` with your unique application ID in Android Gradle configuration before publishing.
- Create and protect your own Android upload keystore; never commit it or its passwords.
- Configure signing values as GitHub Actions secrets only after reviewing the release workflow.
- Review the QA checklist, privacy disclosures, store listing, screenshots, icon, and Play Console requirements.
- A successful CI build does not guarantee Google Play approval. Test on a real device first.

## Current MVP limitations
- The visual board is an early custom-painted layout, not yet a pixel-accurate 52-cell path.
- Move animation, sound playback/persistence, and complete comprehensive rule tests remain to be completed.
- Treat this branch as a development build, not a Play Store-ready release.
