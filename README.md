# NeonVault — Obsidian Mint Code Snippet Manager

A beautiful Flutter app for managing code snippets, styled with the Obsidian Mint design system.

## Features

- 📚 **Library** — Bento-style grid of all your snippets, sorted by latest or popularity
- 🔖 **Saved** — Bookmarked snippets for quick access
- 🏷️ **Tags & Search** — Filter by language, tag, or full-text search
- ➕ **Add/Edit** — Create and edit snippets with a built-in code editor
- 📋 **Copy** — One-tap copy to clipboard, with copy count tracking
- 🗂️ **Local Storage** — Snippets saved to `NeonVault/` folder on device
- 📄 **File Export** — Each snippet also saved as individual `.py`, `.js`, `.ts` etc. files

## Storage Location

On **Android**: `Android/data/com.example.neonvault/files/NeonVault/`  
On **iOS**: App Documents directory → `NeonVault/`

Files stored:
- `snippets_index.json` — Full index of all snippets
- Individual snippet files (e.g. `DebounceFunction_abc123.js`)

## Setup

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release

# Build release for iOS
flutter build ios --release
```

## Dependencies

- `path_provider` — Access device file system
- `uuid` — Generate unique IDs for snippets
- `intl` — Date formatting
- `share_plus` — Share snippets
- `google_fonts` — Typography
- `animations` — Smooth transitions

## Architecture

```
lib/
├── main.dart              # App entry + root scaffold
├── theme.dart             # Colors, typography, language colors
├── models/
│   └── snippet.dart       # Snippet data model
├── services/
│   └── storage_service.dart  # Local file I/O
├── screens/
│   ├── library_screen.dart   # Home / grid view
│   ├── detail_screen.dart    # Snippet viewer
│   ├── add_screen.dart       # Create / edit screen
│   ├── saved_screen.dart     # Bookmarked snippets
│   └── tags_screen.dart      # Search & filter
└── widgets/
    └── shared_widgets.dart   # Reusable components
```
