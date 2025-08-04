# Advisor Desk: Performance & Salary Tracker

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Advisor Desk Logo" width="150"/>
</p>

<p align="center">
  <strong>The ultimate all-in-one productivity app for freelance and work-from-home (WFH) customer care advisors.</strong>
  <br />
  Track daily login hours, call counts, performance metrics, and instantly calculate your estimated salary—all in a secure, offline-first app.
</p>

<p align="center">
  <a href="https://github.com/suvojit213/Advisor-Desk/stargazers"><img src="https://img.shields.io/github/stars/suvojit213/Advisor-Desk?style=for-the-badge" alt="Stars"></a>
  <a href="https://github.com/suvojit213/Advisor-Desk/network/members"><img src="https://img.shields.io/github/forks/suvojit213/Advisor-Desk?style=for-the-badge" alt="Forks"></a>
  <a href="https://github.com/suvojit213/Advisor-Desk/issues"><img src="https://img.shields.io/github/issues/suvojit213/Advisor-Desk?style=for-the-badge" alt="Issues"></a>
  <a href="https://github.com/suvojit213/Advisor-Desk/blob/main/LICENSE"><img src="https://img.shields.io/github/license/suvojit213/Advisor-Desk?style=for-the-badge" alt="License"></a>
</p>

---

## ✨ Overview

**Advisor Desk** is a robust and intuitive mobile application built with Flutter, meticulously designed to empower freelance and remote customer service advisors. It provides a comprehensive suite of tools to efficiently manage daily tasks, monitor performance metrics, and accurately calculate monthly earnings. With a strong emphasis on a clean user interface, user privacy, and practical functionalities, this app serves as an indispensable tool for agents to stay organized, motivated, and in complete control of their performance and finances.

The app is built with a **secure, offline-first** architecture, ensuring that all user data is stored exclusively on the device. No internet connection, sign-up, or cloud services are required, guaranteeing absolute privacy.

## 🚀 Key Features

This application is packed with features engineered for seamless and efficient performance tracking:

-   **📊 Smart Performance Dashboard:**
    -   Log daily login hours, calls handled, and quality scores (CSAT & CQ).
    -   View at-a-glance cards for total calls, login hours, login days, and daily averages.
    -   Easily edit or delete any entry to keep records accurate.

-   **💰 Instant Salary Estimation:**
    -   Get a detailed, automated breakdown of your estimated monthly earnings:
        -   **Base Salary** (based on call volume)
        -   **Performance Bonus** (for achieving targets)
        -   **CSAT & CQ Bonuses** (based on quality scores)
        -   **TDS Deduction** & Final **Net Salary**
    -   Customize all salary parameters in the settings to match your specific pay structure.

-   **🎯 Motivational Goal Tracking:**
    -   Set monthly goals for login hours and call counts.
    -   Visualize your progress in real-time with beautiful, animated circular progress bars.
    -   Stay focused and consistently hit your targets with a clear view of what's needed.

-   **📄 Professional PDF & Excel Reports:**
    -   Instantly generate detailed performance reports for any custom date range.
    -   Customize reports to include only the sections you need (e.g., Salary Breakdown, Daily Entries).
    -   Export to both **PDF** for easy sharing and **Excel** for record-keeping or analysis.
    -   Share reports effortlessly via WhatsApp, Gmail, or any other app.

-   **🔒 Secure, Private & Offline-First:**
    -   All data is stored securely on your device's local database using **SQFlite**.
    -   **No Internet Required.** The app works perfectly offline.
    -   **No Sign-Up, No Cloud Sync.** Your privacy is our priority. We collect zero personal data.
    -   **100% Ad-Free.** No ads, trackers, or third-party analytics.

-   **✨ Modern & Smooth UI:**
    -   A sleek and intuitive user interface built with Flutter for a fast, responsive experience.
    -   Choose between a beautiful **Light or Dark mode**.
    -   Clean, simple navigation designed for a focused workflow.

-   **🔧 Advanced Settings & Control:**
    -   Full control over salary and bonus parameters.
    -   Options to delete specific data points (e.g., daily CSAT/CQ scores) to correct errors.
    -   Backup and restore your entire database.

## 🛠️ Tech Stack & Architecture

This project is built using cutting-edge technologies and adheres to a clean architecture, specifically the **BLoC (Business Logic Component)** pattern for robust and scalable state management.

-   **Framework:** Flutter
-   **Language:** Dart
-   **Architecture:** BLoC (Business Logic Component)
-   **State Management:** `flutter_bloc`
-   **Local Database:** `sqflite`
-   **Key Packages:**
    -   `equatable`: For value equality checks in BLoC states.
    -   `path_provider`: For accessing the file system.
    -   `intl`: For date/number formatting.
    -   `fl_chart` & `percent_indicator`: For data visualization.
    -   `shared_preferences`: For storing user settings.
    -   `pdf` & `excel`: For native report generation.
    -   `share_plus`: For native sharing capabilities.
    -   `permission_handler`: For runtime permission requests.

## 🚀 Getting Started

To get a local copy of the project up and running for development or testing, follow these simple steps.

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.x or higher)
-   A code editor such as [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/).

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/suvojit213/Advisor-Desk.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd Advisor-Desk
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Don't forget to give the project a star! Thanks again!

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Contact

**Suvojeet Sengupta** - suvojitsengupta21@gmail.com

Project Link: [https://github.com/suvojit213/Advisor-Desk](https://github.com/suvojit213/Advisor-Desk)

## 🙏 Acknowledgements

-   A huge thank you to **Di Bhai (Mouma)** and **Sudhanshu** for their rigorous testing, invaluable feedback, and feature suggestions that have shaped this app.
-   To everyone else who has contributed and supported this project.