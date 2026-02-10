# PersonalityQuiz Documentation

## Overview
PersonalityQuiz is an iOS app that lets users take a personality quiz, see their result, and view a history of completed quizzes. The app supports multiple quiz sets, randomized question order, randomized answers for single/multiple questions, and optional timed mode (per-question time limit).

## Features
- Multiple quizzes selectable from the intro screen
- Randomized question order each run
- Randomized answer order for single and multiple choice questions
- Timed quiz mode with per-question countdown
- Results screen with personality outcome
- Local history screen listing completed quizzes and results

## Project Structure
Key files:
- `PersonalityQuiz/AppDelegate.swift`
- `PersonalityQuiz/IntroductionViewController.swift`
- `PersonalityQuiz/QuestionViewController.swift`
- `PersonalityQuiz/ResultsViewController.swift`
- `PersonalityQuiz/HistoryViewController.swift`
- `PersonalityQuiz/QuestionData.swift`
- `PersonalityQuiz/QuizHistoryStore.swift`
- `PersonalityQuiz/Base.lproj/Main.storyboard`

## How It Works
### Quiz Data
Quiz content is defined in `QuestionData.swift`:
- `Quiz` holds a title and list of questions
- `Question` contains text, response type, and answers
- `Answer` contains text and `AnimalType`
- `QuizBank` stores all quizzes

### Question Flow
`QuestionViewController`:
- Shuffles questions on load
- Builds dynamic UI for single and multiple questions using stack views
- Handles ranged questions using a slider
- Tracks selected answers
- Navigates to Results

### Timed Mode
- Toggle on/off from the intro screen
- Time limit is per question
- When time expires:
  - Single: skips
  - Multiple: submits current toggles
  - Ranged: submits current slider value
- Total elapsed time is stored in history

### History
`QuizHistoryStore` uses `UserDefaults` to persist history entries:
- quiz title
- date completed
- result emoji
- timed flag and time limit
- total elapsed time

`HistoryViewController` displays entries in a table view.

## UI / Storyboard
All UI is defined in `Main.storyboard`:
- Intro screen: quiz selection, timed toggle, history button
- Question screen: question text, answer stack views, timer label, progress
- Results screen: result emoji and description
- History screen: list of completed quizzes

## Running the App
1. Open `PersonalityQuiz/PersonalityQuiz.xcodeproj` in Xcode.
2. Select a simulator or device.
3. Run.

## Customization
- Add or edit quizzes in `QuestionData.swift`.
- Adjust timed quiz duration in `IntroductionViewController.swift` (`timeLimitSeconds`).
- Update UI colors/fonts directly in `Main.storyboard`.

## Notes
- Timed quiz only affects questions while answering.
- History is stored locally on-device and is not synced.
