# Moodify

Moodify is a Flutter-based mobile application designed to support mental health tracking and crisis management. It provides users with tools to log their moods, take mental health assessments, generate reports, access emergency resources, and receive AI-driven insights into their mental well-being.

## 📦 Download

Download the latest APK release here:

[![Download APK](https://img.shields.io/badge/Download-APK-blue.svg)](https://github.com/GGBJacob/Moodify/releases/download/v2.0.0/Moodify-v2.0.0.apk)

## Features

### 1. Note Storage with Supabase
- **Description**: Users can store notes in a Supabase backend, capturing their mental state and activities.
- **Details**:
  - Notes include:
    - **Mood**: User's emotional state on a 5-step scale, ranging from Very Sad (0), Sad (1), Neutral (2), Happy (3), to Very Happy (4), visualized with corresponding icons.
    - **Activities**: Activities performed during the day.
    - **Emotions**: Specific emotions experienced.
    - **Text Notes**: Free-form text up to 1000 characters.
  - Securely stored and retrieved using Supabase's real-time database.

### 2. PHQ-9 Test Implementation
- **Description**: A standardized Patient Health Questionnaire (PHQ-9) test to assess depression severity.
- **Details**:
  - Users can complete the PHQ-9 test within the app.
  - Test results are saved for tracking progress over time.
  - Provides insights into mental health status based on scores.

### 3. Report Generation
- **Description**: Generate PDF reports summarizing notes from a specified time period.
- **Details**:
  - Users select a start and end date to export notes.
  - Reports include mood, activities, emotions, and test results.
  - Exported as a PDF for personal records or sharing with professionals.

### 4. Login / Sign Up
- **Description**: Secure user authentication to protect personal data.
- **Details**:
  - Supports login and sign-up via email/password.
  - Powered by Supabase Auth for secure session management.

### 5. Emergency Phone Numbers
- **Description**: Quick access to emergency mental health hotlines for various countries.
- **Details**:
  - Direct dialing for specific numbers (e.g., Poland: 116 123, EU: 112, US/Canada: 988).
  - A popup dialog displays these hotlines, allowing users to select and call a number instantly.
  - Integrated with `url_launcher` for seamless phone calls.

### 6. AI-Driven Note Assessment powered by an LLM
- **Description**: Uses an OpenAI text embeddings model to analyze notes and assess mental health risks.
- **Details**:
  - Notes are scored based on their content.
  - Measures cosine distance of note scores from predefined mental health categories:
    - Addiction, ADHD, Alcoholism, Anxiety, Autism, Bipolar, Borderline, Depression, Health Anxiety, Lonely, PTSD, Social Anxiety, Suicide.
  - Provides a risk calculation to identify potential mental health concerns.

## Getting Started

### Prerequisites
- **Flutter**: Version 3.0.0 or higher.
- **Dart**: Version 2.17.0 or higher.
- **Supabase Account**: For backend storage and authentication.
- **IDE**: Android Studio, VS Code, or another Flutter-compatible IDE.
- **Device/Emulator**: For testing (iOS or Android).

### Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/moodify.git
   cd moodify
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Usage
1. **Sign Up / Log In**: Create an account or log in to access the app.
2. **Log Notes**: Record your mood, activities, emotions, and text notes daily.
3. **Take PHQ-9 Test**: Complete the depression assessment and view saved results.
4. **Generate Reports**: Select a date range to export your notes summary as a PDF.
5. **Access Emergency Numbers**: Dial a hotline directly or view a list of numbers in the emergency popup.
6. **View AI Insights**: Check AI-generated risk assessments based on your notes.

## Dependencies
- `flutter`: Core framework for building the app.
- `supabase_flutter`: For backend storage and authentication.
- `table_calendar`: For a monthly notes view.
- `shared_prefs`: For settings storing.
- `url_launcher`: For dialing emergency numbers and launching websites.
- `pdf`: For generating PDF reports (assumed, based on report generation feature).
- Others as specified in `pubspec.yaml`.

## Contributing
We welcome contributions! To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m 'Add your feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

## License
This project is developed as part of a course at Gdańsk University of Technology (GUT). The licensing status is currently undefined; please contact the project team for details.

## Contact
For questions or support, please reach out to the project team or open an issue on GitHub.

## Acknowledgments
- Built with Flutter and Supabase.
- Developed as a student project for a course at Gdańsk University of Technology (GUT).
- Emergency numbers sourced from public mental health resources.