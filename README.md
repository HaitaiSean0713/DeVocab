# DeVocab

🌐 **Live Demo:** [https://HaitaiSean0713.github.io/DeVocab/](https://HaitaiSean0713.github.io/DeVocab/)

DeVocab is a Flutter Web application designed for vocabulary learning and management. It provides a clean, modern interface for users to search, save, and review English words, leveraging AI to generate detailed explanations, example sentences, and synonyms.

## Features

*   **Google Authentication:** Secure and simple sign-in using personal Google accounts via Supabase Auth.
*   **AI-Powered Definitions:** Integrates with the Google Gemini API to dynamically generate comprehensive word definitions, including part of speech, Chinese meanings, English explanations, and example sentences.
*   **Personalized Favorites:** Users can save their favorite words for later review.
*   **Data Isolation:** User data (favorites, settings) is securely isolated using unique user IDs.
*   **Responsive Design:** A beautiful, glassmorphism-inspired UI that adapts to both mobile and desktop screens.
*   **Customizable Settings:** Users can manage their profile, including setting a custom name and avatar emoji.

## Tech Stack

*   **Frontend Framework:** [Flutter](https://flutter.dev/)
*   **Backend & Authentication:** [Supabase](https://supabase.com/)
*   **AI Integration:** Google Gemini API
*   **State Management:** `provider`
*   **Routing:** `go_router`
*   **Local Storage:** `shared_preferences`, `flutter_secure_storage`
*   **Deployment:** GitHub Pages (via GitHub Actions)

## Setup and Installation

### Prerequisites

*   Flutter SDK (>=3.0.0 <4.0.0)
*   A Supabase Project
*   A Google Gemini API Key

### Configuration

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/HaitaiSean0713/DeVocab.git
    cd DeVocab
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Variables:**
    Create a `.env` file in the root directory and add your Supabase credentials:
    ```env
    SUPABASE_URL=your_supabase_project_url
    SUPABASE_ANON_KEY=your_supabase_anon_key
    ```
    *Note: The Gemini API key is entered by the user within the app UI upon first login.*

4.  **Run the app locally:**
    ```bash
    flutter run -d chrome
    ```

## Project Structure

*   `lib/models/`: Data classes (e.g., `WordData`).
*   `lib/providers/`: State management for words, favorites, and settings.
*   `lib/router/`: Application routing configuration (`app_router.dart`).
*   `lib/screens/`: UI pages (Home, Login, Settings, Favorites, Word Detail, API Setup).
*   `lib/services/`: Integration with external APIs (Supabase, Gemini) and local storage.
*   `lib/theme/`: Global styling, colors, and typography.

## Deployment

This project uses GitHub Actions for continuous deployment to GitHub Pages.
Any push to the `main` branch automatically triggers the `.github/workflows/deploy.yml` workflow, which builds the Flutter Web app and publishes it to the `gh-pages` branch.

## License

This project is licensed under the MIT License.
