# Client test APK

Generate the public-only configuration before any Flutter build:

```powershell
python tools/generate_public_config.py
```
Do not redistribute older builds containing the private .env asset. See docs/security_review.md.

Home and Search are enabled by default again, including the mobile search button
and direct Search route. Normal development uses `flutter run` without feature
flags. The client-test artifacts already generated remain unchanged.

To create another restricted client-test build, explicitly disable both screens.
Add Booking, Calendar, Archive, and administrator Reports remain available.
The Search route redirects to the booking workspace while Search is disabled.

Build the client APK:

```powershell
flutter build apk --release --dart-define=ENABLE_EMPLOYEE_HOME=false --dart-define=ENABLE_BOOKING_SEARCH=false
```

Explicitly enable both screens when overriding an earlier restricted command:

```powershell
flutter run --dart-define=ENABLE_EMPLOYEE_HOME=true --dart-define=ENABLE_BOOKING_SEARCH=true
flutter build apk --release --dart-define=ENABLE_EMPLOYEE_HOME=true --dart-define=ENABLE_BOOKING_SEARCH=true
```

Both `defaultValue` arguments in `lib/core/config/app_features.dart` are `true`.
Re-run the app without any `false` feature flags after switching builds.

The APK uses the project's existing Android signing configuration.

## Windows

```powershell
flutter build windows --release --dart-define=ENABLE_EMPLOYEE_HOME=false --dart-define=ENABLE_BOOKING_SEARCH=false
```

The Windows executable is `build/windows/x64/runner/Release/Dimah_Booking.exe`.
Distribute its companion DLLs and `data` directory along with it, or use the
generated `build/client-test/Dimah-ERP-client-test-Setup.exe` installer.
The portable package is `build/client-test/Dimah-ERP-Windows-client-test.zip`.
