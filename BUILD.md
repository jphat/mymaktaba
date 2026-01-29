

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
flutter pub add firebase_auth ~~firebase_database~~ cloud_firestore
flutterfire configure

`rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}`