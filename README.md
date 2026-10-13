# Euro 24 Fantasy

A fantasy football app for the UEFA Euro 2024 tournament, built in three weeks in May 2024 by a team of two.

Users sign in, pick a squad from the tournament's player pool, and track players' stats and fantasy points. The tournament view shows group tables and fixtures.

## Features

- **Sign-in and registration** with Firebase Auth and Google Sign-In
- **Squad builder**: search and filter the player pool by name, team and position, compare prices and points, and save a squad to Firebase Realtime Database
- **Player stats**: goals, assists, clean sheets, cards and fantasy points per player, ranked by points on the home screen
- **Tournament view**: group tables, plus fixtures scraped from ESPN's Euro 2024 schedule page

## Stack

Flutter / Dart · Firebase Auth · Google Sign-In · Firebase Realtime Database · `http` · `shared_preferences`

## Run it

Requires a Firebase project with Auth (email + Google) and Realtime Database enabled.

```bash
flutter pub get
flutterfire configure   # point the app at your own Firebase project
flutter run
```

## Team

Built by [Aarav Samal](https://github.com/aaravSmall) and [Ibrahim Yousuf](https://github.com/IbrahimYousuf22).
