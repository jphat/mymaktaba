# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

- /

## [0.0.8] - 2026-02-01

### Added

- **UI Component**: Created reusable [CustomAppBar](lib/widgets/custom_app_bar.dart) widget for consistent navigation and styling across screens.
- **Book Details Screen**: Added [BookViewScreen](lib/screens/book_view_screen.dart) with full book information display, including cover image, metadata, and action buttons.
- **Expandable Description**: Implemented collapsible description with 4-line preview and "Show more/less" toggle in BookViewScreen.
- **Book Actions**: Added Share, Edit, and Delete functionality with confirmation dialog in BookViewScreen.

### Changed

- **Navigation**: Updated [HomeScreen](lib/screens/home_screen.dart) to navigate to BookViewScreen when a book item is tapped.
- **Consistent UI**: Migrated [HomeScreen](lib/screens/home_screen.dart), [SearchScreen](lib/screens/search_screen.dart), [ExportScreen](lib/screens/export_screen.dart), and [AddBookScreen](lib/screens/add_book_screen.dart) to use CustomAppBar.

### Fixed

- Fixed corrupted code in [BookViewScreen](lib/screens/book_view_screen.dart) that caused compilation errors.

## [0.0.7] - 2026-01-29

### Added

- **Cloud Storage**: Integrated **Firebase Cloud Firestore** for reliable cloud-based data persistence.
- **Security**: Added `firestore.rules` to enforce strict user-scoped data access (users can only read/write their own books).
- **Dependencies**: Added `cloud_firestore`.

### Changed

- **Storage Architecture**: Migrated data storage from local SQLite (`sqflite`) to Firestore. Books are now saved under `users/{userId}/books`.
- **Data Model**: Updated [Book](lib/models/book.dart) model to use String IDs instead of integers for compatibility with Firestore document keys.
- **State Management**: completely rewrote [BookProvider](lib/providers/book_provider.dart) to handle asynchronous Firestore operations (add, update, delete, fetch).
- **Sharing**: Updated export functionality in `BookProvider` to correctly use `SharePlus.instance.share`.

### Removed

- **Legacy Storage**: Deleted [database_helper.dart](lib/services/database_helper.dart) and removed local SQLite implementation.
- **Dependencies**: Removed `firebase_database` (Realtime Database) in favor of Firestore.

## [0.0.6] - 2026-01-29

### Added

- **Authentication System**: Implemented full support for Email/Password, Google, and Apple Sign-In.
- **Screens**: Added [LoginScreen](lib/screens/login_screen.dart) and [AccountScreen](lib/screens/account_screen.dart).
- **Tests**: Added unit and widget tests for authentication flow and navigation.
- **iOS**: Added `Runner.entitlements` to enable "Sign in with Apple" capability.

### Changed

- **UI**: Redesigned [HomeScreen](lib/screens/home_screen.dart) AppBar with left-aligned title and user profile icon.
- **Navigation**: Updated [main.dart](lib/main.dart) to act as an auth gate, redirecting to login if needed.
- **Dependencies**: Added `google_sign_in` and `sign_in_with_apple`.
- Minimum iOS version to 15.

### Fixed

- Resolved iOS CocoaPods dependency conflicts causing Google Sign-In failures.
- Fixed Apple Sign-In error 1000 by correctly configuring project entitlements.


## [0.0.5] - 2026-01-28

### Added

- Updated [book.dart](lib/models/book.dart) model to include `dateAdded` and `dateModified` fields.
- Updated [database_helper.dart](lib/services/database_helper.dart) to version 2, adding schema migrations and automatic timestamp updates for new and edited books.
- Firebase MCP in [.vscode/mcp.json](.vscode/mcp.json)

## [0.0.4] - 2026-01-28

### Added

- Added support for environment variables in [.gitignore](.gitignore).

### Changed

- Updated iOS project identity: set Bundle Identifier to `me.josephat.mymaktaba` and Display Name to "MyMaktaba" in [project.pbxproj](ios/Runner.xcodeproj/project.pbxproj) and [Info.plist](ios/Runner/Info.plist).
- Migrated code to use the latest `SharePlus` API for exports and sharing in [book_provider.dart](lib/providers/book_provider.dart) and [home_screen.dart](lib/screens/home_screen.dart).
- Refactored [api_service.dart](lib/services/api_service.dart) to use `developer.log` instead of `print`.
- Modified [analysis_options.yaml](analysis_options.yaml) to allow `print` statements.

### Fixed

- Removed unused import in [home_screen.dart](lib/screens/home_screen.dart).


## [0.0.3] - 2026-01-21

### Fixed

- [Scanner Screen](lib/screens/scanner_screen.dart) crashing after scanning a barcode

## [0.0.2] - 2026-01-21

### Added

- [TODO](TODO.md) to keep a running list of features

### Changed

- pod install in iOS app

## [0.0.1] - 2026-01-21

- initial release

<!-- Links -->
[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html

<!-- Versions -->
[unreleased]: https://github.com/jphat/mymaktaba/compare/v0.0.8...HEAD
[0.0.8]: https://github.com/jphat/mymaktaba/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/jphat/mymaktaba/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/jphat/mymaktaba/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/jphat/mymaktaba/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/jphat/mymaktaba/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/jphat/mymaktaba/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/jphat/mymaktaba/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/jphat/mymaktaba/releases/tag/v0.0.1