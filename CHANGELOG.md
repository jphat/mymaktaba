# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

- /

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
[unreleased]: https://github.com/jphat/mymaktaba/compare/v0.0.4...HEAD
[0.0.4]: https://github.com/jphat/mymaktaba/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/jphat/mymaktaba/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/jphat/mymaktaba/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/jphat/mymaktaba/releases/tag/v0.0.1