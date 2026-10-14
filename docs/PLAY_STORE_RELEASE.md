# Google Play Store release checklist

## Current status

**Not ready for public release yet.** The current branch is an early MVP scaffold. The board path and token movement visuals, complete rules coverage, sound behavior, and physical-device QA are unfinished. Do not upload this build as a finished game.

## Before creating a Play Console release

1. Finish the game UI and verify all Ludo rules, including entering from base on six, safe squares, captures, exact finish, extra turns, and three consecutive sixes.
2. Run `flutter analyze`, `flutter test`, and `flutter build appbundle --release`; resolve all failures.
3. Choose a permanent unique Android application ID (for example, a reverse-domain ID under a domain you control). Once published, changing it creates a different app.
4. Set the app name, launcher icon, version, Android target SDK, and release signing configuration.
5. Create an upload keystore locally and back it up securely. Never commit the keystore or passwords to Git.
6. Configure the GitHub Actions secrets listed below only after reviewing the workflow. Do not paste secrets into issues, chat, or repository files.
7. Test the signed release on a physical Android device before uploading.
8. Prepare the Play listing: app name, short/full descriptions, phone screenshots, high-resolution icon, feature graphic, support contact, and privacy policy URL.
9. Complete Play Console app-content declarations accurately (data safety, ads, target audience, content rating, app access). This game is intended to work offline without accounts, ads, payments, or a backend; verify actual behavior before declaring this.
10. Upload the signed AAB to an internal testing track first. Test it, fix issues, then submit for review.

## Signing secret design

For a GitHub Actions release build, use repository **Actions secrets** for:
- `ANDROID_KEYSTORE_BASE64`: base64-encoded upload keystore file
- `ANDROID_KEYSTORE_PASSWORD`: keystore password
- `ANDROID_KEY_ALIAS`: upload key alias
- `ANDROID_KEY_PASSWORD`: upload key password

Keep the keystore backed up offline. Do not enable the release workflow until signing configuration is implemented and verified. The current workflow only produces a debug APK and conditionally attempts an AAB based on a repository variable; it does not yet configure secure signing.

## Build locally

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build appbundle --release
```

The release AAB should appear at `build\app\outputs\bundle\release\app-release.aab` when signing and Android project configuration are correct. Do not upload an unsigned or debug build to production.
