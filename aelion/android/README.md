# Aelion Android

This directory contains the first Android app scaffold for Aelion.

## What is included

- Kotlin Android app module (`app`)
- Native bridge using Android NDK + CMake
- Launcher activity that calls into native code

## Open in Android Studio

1. Open the `android` folder as a project.
2. Let Android Studio install required SDK/NDK components.
3. Build and run on an emulator or device.

## Build from command line

From this `android` directory:

```bash
gradle assembleDebug
```

If your system does not have `gradle`, use Android Studio to generate and use a Gradle wrapper.

## Next integration step

Wire Aelion core runtime functions into `app/src/main/cpp/aelion_android_bridge.c` to execute real engine commands from the Android UI.

## Release pipeline

This repository now includes a GitHub Actions workflow at `.github/workflows/android-release.yml`.

- Trigger it manually from Actions, or push a tag like `v0.2.0`.
- It builds release APK and AAB artifacts.
- For real signing, set these repository secrets:
  - `AELION_UPLOAD_STORE_FILE` (path on runner to keystore file)
  - `AELION_UPLOAD_STORE_PASSWORD`
  - `AELION_UPLOAD_KEY_ALIAS`
  - `AELION_UPLOAD_KEY_PASSWORD`

If signing secrets are not provided, the release build falls back to debug signing so CI still produces installable artifacts for testing.
