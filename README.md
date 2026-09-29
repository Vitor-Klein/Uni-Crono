# Uni Cronos

O **Uni Cronos** é um aplicativo desenvolvido para ajudar estudantes a acompanhar e gerenciar suas horas complementares e extracurriculares de forma prática. 

O grande diferencial do projeto é a funcionalidade de **upload de certificados**: ao enviar o documento, um script automatizado realiza a leitura do arquivo, extrai as informações de carga horária e já contabiliza as horas automaticamente no grupo ou categoria corretos de atividades.

## 🌟 Funcionalidades Principais

* **Gestão de Horas:** Visualize facilmente o total de horas acumuladas e o progresso das suas metas, divididas por categoria.
* **Upload e Leitura Inteligente:** Faça o upload dos seus certificados e deixe o sistema extrair os dados automaticamente.
* **Categorização Automática:** As horas são interpretadas e alocadas no grupo de atividades certo, poupando o trabalho manual de cadastro.

## 🎨 Protótipo e Design

O design e as telas do aplicativo podem ser visualizados no Figma:
- [Acessar Protótipo no Figma](https://www.figma.com/design/vNP3TPcSQFyIJEEPhlqSCE/Untitled?node-id=0-1&t=1HmSgf8XhXO0iEt8-1)

---

## 🛠️ Quick Start (Desenvolvimento)

O projeto foi gerado a partir do *base_nextup_template* (Flutter). Para rodar localmente:

```bash
# Instalar as dependências
flutter pub get

# Rodar o app
flutter run

# Analisar o código (custom lint rules)
dart run custom_lint
```

## ⚙️ Remote Config

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

## 📱 App Icons

`assets/icon/playstore.png` and `assets/icon/appstore.png` ship with a placeholder. Replace them with real branding before publishing, then regenerate:

```bash
# Required files:
# assets/icon/playstore.png  — 512×512 px (Android), opaque (no alpha channel)
# assets/icon/appstore.png   — 1024×1024 px (iOS), opaque (no alpha channel)

dart run flutter_launcher_icons
```

### Notification Icon

Android's status bar renders the *small icon* using only its alpha channel. 
- **App icon** (`assets/icon/*.png`): opaque, full-color square.
- **Notification icon** (`android/app/src/main/res/drawable-*/ic_notification.png`): monochrome white silhouette on a fully transparent background.

## 🖼️ Splash Screen

Replace `assets/splash.png` with the project splash image.

## 🔥 Firebase

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
