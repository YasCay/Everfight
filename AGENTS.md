# Boss-Rush Roguelite (Flutter)
Game name: Everfight

Single-file guide for coding agents. Focus: Build, Test, Style, Security.

## Repo Map (Short)

* `pubspec.yaml` – Dependencies, lints
* `lib/domain/` – Entities, RNG, combat sim
* `lib/state/` – Riverpod providers, RunState, autosave
* `lib/ui/` – Widgets, screens, animations
* `assets/` – Images/SFX (if used)
* `test/` – Unit, widget, golden
* `analysis_options.yaml` – Lints
* `tool/` – optional scripts

## Setup & Environment

* OS: macOS/Linux/Windows
* Flutter: **3.24+**, Dart: **3.5+**
* Android SDK, Xcode (for iOS)
* Optional: **FVM** for fixed SDK versions
* No backend services, no DB server
* RNG deterministic via seed in `RunState`

### Check versions

```bash
flutter --version
dart --version
```

### SDK via FVM (optional)

```bash
dart pub global activate fvm
fvm install 3.24.0
fvm use 3.24.0
```

## Install

```bash
flutter pub get
```

## Build & Run (Dev)

* Android:

```bash
flutter run -d android
```

* iOS (Simulator):

```bash
flutter run -d ios
```

* Web:

```bash
flutter run -d chrome
```

* Desktop (if enabled):

```bash
flutter run -d windows   # or macos, linux
```

## Build (Prod)

* Android App Bundle:

```bash
flutter build appbundle --release
```

* iOS IPA (requires codesign):

```bash
flutter build ipa --release
```

* Web:

```bash
flutter build web --release
```

* Desktop:

```bash
flutter build windows --release
```

## Run Configurations

* `--dart-define=BUILD_ENV=prod|dev`
* `--dart-define=FEATURE_FLAME=true|false`

Examples:

```bash
flutter run --dart-define=BUILD_ENV=dev --dart-define=FEATURE_FLAME=false
```

## Tests

* All tests:

```bash
flutter test
```

* With coverage (lcov):

```bash
flutter test --coverage
genhtml coverage/lcov.info --output-directory coverage/html
```

* Single package/directory:

```bash
flutter test test/domain
```

* Update goldens:

```bash
flutter test --update-goldens
```

### Test Layout

* Unit: `test/domain/**_test.dart`
* Widget: `test/ui/**_test.dart`
* Golden: `test/ui/golden/**_golden_test.dart`

### Minimum Requirements

* New modules: ≥85% line coverage
* No test may contain `skip`
* RNG tests: same seed ⇒ identical sequence

## Lint & Format

* Analyze:

```bash
dart analyze
```

* Formatting (check):

```bash
dart format --output=none --set-exit-if-changed .
```

* Auto-fix (careful):

```bash
dart fix --apply
```

* Lint preset: `flutter_lints` in `analysis_options.yaml`

## Game Rules (Machine Notes)

* Combat: Player phase (team sequentially) → Boss phase (one hit)
* Healing: Full heal after victory
* Autosave: after combat ends and every selection
* Starter: 2 cards, different elements, player picks 1
* Team limit: 5
* No DEF value in model; see domain formulas
* Element multipliers: fixed 4×4 matrix in `domain/elements.dart`
* Events: Spawn per `LevelConfig.spawnChance`, select exactly **one** option

## Data Persistence

* Format: JSON in app storage
* Interface:

    * `RunState.toJson()` / `fromJson()`
    * Save: on autosave triggers
* Storage path:

    * Mobile/Desktop: `path_provider` app dir
    * Web: `localStorage` fallback

## CLI Tasks (Optional, if `make` available)

```Makefile
install:      flutter pub get
analyze:      dart analyze
format:       dart format .
test:         flutter test
coverage:     flutter test --coverage
run-web:      flutter run -d chrome
build-web:    flutter build web --release
```

## Docker (Optional for CI)

* No runtime Docker needed.
* For reproducible CI:

```Dockerfile
FROM ghcr.io/cirruslabs/flutter:3.24.0
WORKDIR /app
COPY . .
RUN flutter pub get && dart analyze && flutter test
```

## CI Hints

* Jobs:

    * `lint`: `dart format --set-exit-if-changed .` + `dart analyze`
    * `test`: `flutter test --coverage`
    * `build-web`: `flutter build web --release` (artifact)
* Local CI replication:

```bash
dart format --output=none --set-exit-if-changed .
dart analyze
flutter test --coverage
```

* Cache: `.pub-cache`, `build/`, `.dart_tool/`

## Migrations/DB

* Not applicable. No DB.

## Security & Secrets Policy

* Never commit secrets.
* Use `--dart-define=KEY=VALUE` for build-time constants.
* Android keystore/iOS provisioning: only via CI secret store.
* No network calls to unknown hosts.
* No file access outside app directory.
* RNG seeds not derived from telemetry.
* Do-not-do:

    * No runtime codegen.
    * No eval/Isolate-spawn with untrusted input.
    * No external scripts loaded from the web.

## Coding Conventions

* Style: Effective Dart
* Naming: `snake_case` for files, `CamelCase` for classes, `lowerCamelCase` for variables
* Folders:

    * `domain/` pure logic, no UI/IO
    * `state/` Riverpod providers, no UI
    * `ui/` only widgets/animations
* Tests mirror folder structure
* Commits: Conventional Commits (`feat:`, `fix:`, `test:`)

## Graphics/Audio

* Asset path registered in `pubspec.yaml`
* Flame optional:

    * If enabled, only particles/FX, do not move game-loop logic

## Performance

* Target: 60 FPS
* Animation duration: 200–500 ms
* No synchronous long-running tasks in UI thread
* Large lists via `ListView.builder`

## Known Issues / Unsupported

* iOS codesign only on macOS
* Web audio depends on browser policy
* Android minSdk/targetSdk not to be changed without approval
* No automatic migration steps available

## Assumptions (AGENTIFY)

* State management: **Riverpod** as default; Bloc not enabled
* No `melos`/monorepo tools
* No proprietary SDKs
* CI: GitHub Actions or similar, but not required
