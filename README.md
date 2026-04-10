# Taap Taap

A modern iOS rebuild of the original **Taap Taap** reaction game.

## Features

- Local multi-player profiles on one device
- Player creation with personalized tile color
- Home screen to select a profile and start playing
- Fast-tap game loop with accelerating tile jumps
- Per-session tap count, multiplier, lives, and score
- On-device leaderboard with top runs

## Tech Stack

- Swift 6
- SwiftUI (app UI)
- Foundation persistence with `UserDefaults`
- Modular core domain in `TaapTaapCore`

## Project Structure

- `Sources/TaapTaapCore/`
  - Game engine and rules
  - Data models
  - Persistence stores
- `TaapTaapiOS/`
  - SwiftUI app entry point
  - Views and view models
  - iOS resources
- `Tests/TaapTaapCoreTests/`
  - Game and persistence unit tests

## iOS Project Generation

This repository includes an `XcodeGen` spec (`project.yml`) for a clean, reproducible Xcode project.

1. Install XcodeGen
2. Run:

```bash
xcodegen generate
```

3. Open `TaapTaap.xcodeproj` in Xcode
4. Build and run on iOS simulator or device

## Gameplay Mechanics

- Starting a match increments the selected player’s game count
- One darker tile is active at a time
- Correct taps:
  - Increase tap counter
  - Increase multiplier
  - Reduce jump interval (faster game)
  - Move active tile to a new position
- Misses or late taps:
  - Reduce lives
  - Reset multiplier
- Game ends when lives reach zero
- Final score is recorded in leaderboard

## Tests

Run core tests with:

```bash
swift test
```
