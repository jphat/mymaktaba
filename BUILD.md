

## iOS
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run

## auth
firebase login
dart pub global activate flutterfire_cli
_add to home_
flutter pub add firebase_core
flutterfire configure
...
flutter pub add firebase_auth firebase_database
flutterfire configure