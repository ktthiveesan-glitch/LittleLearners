# Little Learners

Little Learners is an iOS learning app for kindergarten children in Sri Lanka.
Children learn letters, numbers and shapes through short lessons, finger tracing and a small game,
in English, Sinhala or Tamil.

It was built as an individual assignment for SLIIT SE4041 (Assignment 2, Part A).

## Purpose

Young children in Sri Lanka often grow up with more than one language. Little Learners gives them one
friendly place to see, hear and trace the first letters of English, Sinhala and Tamil, count from 1 to 10
and recognise basic shapes. Parents and teachers can follow the child's progress in a locked parent area.

## Target audience

- **Children aged 3 to 6** (kindergarten), who use the lessons, tracing and the shapes game.
- **Parents and teachers**, who set the app up and check progress in the parent area.

## Features

- **Several children**: each child has their own profile with a name and avatar. When the app opens it asks
  "Who is learning today?", and every child keeps their own stars, progress, tracing history and badges.
- **Onboarding**: the child's name, an avatar and the app language. Shown for each new child.
- **Letters**: English A–Z, 14 Sinhala vowels and 12 Tamil vowels, each with an example word and a picture.
- **Numbers**: 1 to 10 with their names.
- **Lessons**: a big character, its word, and a button that reads it aloud. Swipe to move between characters.
- **Tracing**: the child draws over a dotted guide with a finger. A correct tracing earns a star and confetti.
- **Shapes game**: drag six shapes onto their matching outlines.
- **Rewards**: a sticker book with eight badges to win.
- **Parent area**: behind a maths question. Shows the selected child's stars per day, progress per category
  and recent tracing. Parents can edit or delete a child here, and change the language, sound and reset progress.
- **Three languages**: English, Sinhala and Tamil, switchable at any time without restarting the app.
- **Accessibility**: Dynamic Type, Dark Mode, VoiceOver labels and touch targets of at least 60 points.
- **Privacy**: all data stays on the device. The app makes no network calls and has no ads or analytics.

### How tracing is checked

- **English letters and digits** are read with Apple's Vision framework (`VNRecognizeTextRequest`),
  which runs on the device. Vision is made for words, not for one large hand-drawn letter, so it does not
  always recognise a good tracing. When Vision reads nothing, the app falls back to the coverage check below.
- **Sinhala and Tamil letters** cannot be read by Vision. They are checked by coverage: the tracing passes
  when it covers at least 70% of the guide letter and no more than 40% of it lies outside the guide.
  This shows that the child followed the guide; it cannot tell which letter was drawn.

## Technologies

| Area | Technology |
|---|---|
| Language and UI | Swift, SwiftUI |
| Architecture | MVVM with `@Observable` view models |
| Navigation | `NavigationStack` with a typed `Route` enum |
| Data storage | SwiftData (app data), `@AppStorage` (language and sound settings) |
| Machine learning | Vision (`VNRecognizeTextRequest`) |
| Charts | Swift Charts |
| Speech | `AVSpeechSynthesizer` |
| Text outlines for tracing | Core Text |
| Localization | String Catalog (`Localizable.xcstrings`) |
| Tests | Swift Testing (unit tests), XCUITest (UI tests) |

## Requirements

- **Xcode 26.2** or later (the project was built and tested with Xcode 26.2)
- **iOS 17.0** or later, on iPhone or iPad
- macOS with an iOS Simulator installed, or a real device

## How to build and run

**In Xcode**

1. Open `LittleLearners.xcodeproj`.
2. Choose the `LittleLearners` scheme and an iPhone or iPad simulator.
3. Press **⌘R**.

**From the command line**

```sh
# See which simulators are installed
xcrun simctl list devices available

# Build (replace the simulator name with one from the list)
xcodebuild -scheme LittleLearners -destination 'platform=iOS Simulator,name=iPhone 17' build
```

## How to run the tests

In Xcode, press **⌘U**.

From the command line:

```sh
xcodebuild -scheme LittleLearners \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -parallel-testing-enabled NO test
```

`-parallel-testing-enabled NO` runs the UI tests on one simulator, which is more reliable than running
them on several simulator copies at once.

The project has 75 unit tests (in `LittleLearnersTests`) and 20 UI tests (in `LittleLearnersUITests`),
including a launch performance test. The UI tests start the app with the launch argument `-uiTesting`,
which makes it use an empty in-memory database, so the tests never change real data.

## Folder structure

```
LittleLearners/
  App/            App entry point, RootView, Route (navigation)
  Models/         SwiftData models and the app language
  Content/        Built-in letters, numbers, shapes and badges
  ViewModels/     One view model per feature
  Views/
    Onboarding/   Profile picker and the screen that creates a child
    Home/         Main menu
    Lessons/      Character grid and lesson
    Tracing/      Tracing screen and canvas
    Shapes/       Shapes game
    Rewards/      Badge sticker book
    ParentArea/   Parental gate, dashboard and charts
  Components/     Reusable views and view modifiers
  Services/       Handwriting check, coverage check, speech, progress, badges
  Theme/          Colours, spacing and sizes
  Resources/      Localizable.xcstrings (English, Sinhala, Tamil)
  Assets.xcassets Colours with light and dark variants
LittleLearnersTests/      Unit tests (Swift Testing)
LittleLearnersUITests/    UI tests (XCUITest)
AI_LOG.md                 Record of how AI was used to build the app
TRANSLATION_REVIEW.md     Translations for a native speaker to check
```

## Known limitations

- The Sinhala and Tamil translations and example words were written with AI help and still need a check
  by a native speaker (see `TRANSLATION_REVIEW.md`).
- Most devices have no Sinhala voice, so Sinhala letters are shown without the speak button.
- Tracing needs a finger on the screen, so it cannot be done with VoiceOver alone.
- The app language is one setting for the whole app, not one per child.

## Third-party credits

None. The app uses only Apple frameworks. It has no third-party packages, images, fonts or sounds;
the pictures in the app are standard emoji and SF Symbols.
