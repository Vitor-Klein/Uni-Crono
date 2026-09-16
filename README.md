# uni_cronos

Generated from the **base_nextup_template** Mason brick. For full architecture documentation and
how-to guides, see the brick's README in the `next_up_bricks` repository.

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze code (custom lint rules)
dart run custom_lint
```

## Remote Config

Update Remote Config keys from the command line:

```bash
dart run tool/update_config.dart
```

Keys to configure in the Firebase Console:

| Key | Description |
|---|---|
| `android_share_url` | Google Play Store URL |
| `ios_share_url` | App Store URL |
| `contact_url` | Contact page URL (opens in WebView) |
| `privacy_policy_url` | Privacy Policy URL (opens in WebView) |
| `terms_url` | Terms of Use URL (opens in WebView) |

## App Icons

`assets/icon/playstore.png` and `assets/icon/appstore.png` ship with a NextUp placeholder
(cream tile, dark "N") so `dart run flutter_launcher_icons` works out of the box. Replace
them with real branding before publishing, then regenerate:

```bash
# Required files:
# assets/icon/playstore.png  — 512×512 px (Android), opaque (no alpha channel)
# assets/icon/appstore.png   — 1024×1024 px (iOS), opaque (no alpha channel)

dart run flutter_launcher_icons
```

The App Store rejects icons with an alpha channel — export both files as opaque RGB.

### Notification Icon

Android's status bar renders the *small icon* using only its alpha channel: an opaque,
colorful app icon becomes a solid white square. That's why the notification uses a
separate, dedicated asset instead of the app icon:

- **App icon** (`assets/icon/*.png`): opaque, full-color square.
- **Notification icon** (`android/app/src/main/res/drawable-*/ic_notification.png`):
  monochrome white silhouette on a fully transparent background, no background shape.

A placeholder `ic_notification.png` ships in every density bucket (`drawable-mdpi` 24px,
`drawable-hdpi` 36px, `drawable-xhdpi` 48px, `drawable-xxhdpi` 72px, `drawable-xxxhdpi`
96px). To replace it, export a white-on-transparent silhouette from a single master image
and resize it into each bucket, keeping some padding from the edges — the OS adds its own.

iOS has no equivalent asset: it always uses the app icon in notifications, so there's
nothing to embark on that side.

## Splash Screen

Replace `assets/splash.png` with the project splash image.

## Firebase

Firebase was configured automatically during generation. If you need to re-run setup:

```bash
# The Firebase project was created during generation; its ID is saved in .firebaserc.
flutterfire configure \
  --project=<project-id from .firebaserc> \
  --platforms=android,ios,web \
  --android-package-name=app.com.unicronos \
  --ios-bundle-id=app.com.unicronos
```

For iOS push notifications, enable in Xcode:
- Background Modes → Remote notifications
- Push Notifications
