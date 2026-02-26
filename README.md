# Voicely

**Voicely** is an AI-powered voice recording and transcription mobile application built with Flutter. It lets users record audio, automatically transcribe speech to text, generate intelligent summaries, organize recordings into folders, and interact with an AI chatbot — all in one place.

---

## Screenshots

> _Add screenshots or GIFs of the app here (recording screen, transcript view, summary view, chatbot, etc.)_

---

## Features

- 🎙️ **Audio Recording** — Record voice memos with real-time waveform feedback
- 📝 **Automatic Transcription** — Convert recorded audio to text via backend AI service
- 🤖 **AI Summary** — Generate concise summaries from transcriptions using AI
- 💬 **AI Chatbot** — Chat with an AI assistant about your recordings and notes
- 📁 **Folder Management** — Organize recordings and transcripts into custom folders
- 🎧 **Audio Manager** — Browse, play, and manage all saved recordings
- 🔔 **Push Notifications** — Firebase Cloud Messaging (FCM) with local notification support
- 👤 **User Profile** — View and edit profile information
- 🔐 **Authentication** — Secure login, signup, and forgot-password flows
- 🌙 **Custom Theme** — Modern, clean UI with a consistent design system

---

## Getting Started

### Prerequisites

Make sure the following tools are installed on your machine:

| Tool | Version |
|------|---------|
| Flutter SDK | `>=3.7.2` |
| Dart SDK | `^3.7.2` |
| Android Studio or Xcode | Latest stable |
| Android Emulator / iOS Simulator | — |

### Installation

1. **Clone the repository:**

```bash
git clone <repository-url>
cd voicely_fe
```

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Configure Firebase:**

   The project uses Firebase (Core + Messaging). The `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS) files must be in place. These are already present in `android/app/` for the existing setup. If setting up from scratch, follow the [Firebase Flutter setup guide](https://firebase.google.com/docs/flutter/setup).

4. **Configure the backend API URL:**

   Update the base URL in:
   ```
   lib/core/constants/app_constants.dart
   ```

5. **Run the application:**

```bash
flutter run
```

---

## Usage

| Command | Description |
|---------|-------------|
| `flutter run` | Run the app in debug mode |
| `flutter run --release` | Run the app in release mode |
| `flutter build apk` | Build Android APK |
| `flutter build ios` | Build iOS app |
| `flutter test` | Run unit & widget tests |
| `flutter pub get` | Install/update dependencies |

---

## Project Structure

```
lib/
├── core/                          # Shared core functionality
│   ├── constants/                 # App-wide constants & API config
│   ├── errors/                    # Failure & exception types
│   ├── network/                   # Dio HTTP client configuration
│   ├── routes/                    # go_router navigation setup
│   ├── theme/                     # App theme (colors, typography)
│   └── utils/                     # Utility helpers
├── features/                      # Feature modules (Clean Architecture)
│   ├── auth/                      # Login, signup, forgot password
│   ├── recording/                 # Audio recording
│   ├── transcription/             # Speech-to-text transcription
│   ├── summary/                   # AI-generated summaries
│   ├── chatbot/                   # AI chatbot interface
│   ├── audio_manager/             # Playback & audio list management
│   ├── folders/                   # Folder organization
│   ├── notifications/             # FCM push & local notifications
│   ├── profile/                   # User profile
│   └── landing/                   # Onboarding / landing screen
├── injection_container/           # GetIt dependency injection setup
└── main.dart                      # App entry point
```

Each feature follows the **Clean Architecture** pattern:

```
feature/
├── data/
│   ├── datasources/      # Remote API & local storage sources
│   ├── models/           # JSON-serializable data models
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Pure business entities
│   ├── repositories/     # Abstract repository interfaces
│   └── usecases/         # Business logic use cases
└── presentation/
    ├── bloc/             # BLoC state management
    ├── pages/            # Full-screen UI pages
    └── widgets/          # Reusable UI components
```

---

## Technologies Used

| Category | Library / Technology |
|----------|---------------------|
| **Framework** | [Flutter](https://flutter.dev) 3.x |
| **Language** | Dart `^3.7.2` |
| **State Management** | [flutter_bloc](https://pub.dev/packages/flutter_bloc) `^8.1.3` |
| **Dependency Injection** | [get_it](https://pub.dev/packages/get_it) `^7.6.4` |
| **HTTP Client** | [dio](https://pub.dev/packages/dio) `^5.3.2` |
| **Navigation** | [go_router](https://pub.dev/packages/go_router) `^12.1.1` |
| **Firebase** | firebase_core, firebase_messaging |
| **Local Storage** | shared_preferences, flutter_secure_storage |
| **Audio Recording** | [record](https://pub.dev/packages/record) `^6.0.0` |
| **Audio Playback** | [audioplayers](https://pub.dev/packages/audioplayers) `^6.5.1` |
| **Rich Text Editor** | [flutter_quill](https://pub.dev/packages/flutter_quill) `^11.5.0` |
| **Chat UI** | [flutter_chat_ui](https://pub.dev/packages/flutter_chat_ui) `^1.6.12` |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) `^19.5.0` |
| **File Picker** | [file_picker](https://pub.dev/packages/file_picker) `^10.3.3` |
| **Functional Programming** | [dartz](https://pub.dev/packages/dartz) `^0.10.1` |
| **Value Equality** | [equatable](https://pub.dev/packages/equatable) `^2.0.5` |

---

## License

This project is licensed under the MIT License.
