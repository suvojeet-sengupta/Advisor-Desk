# 📊 Advisor Desk App

## Empowering Professionals with Seamless Performance Tracking

--- 

## ✨ Overview

**Advisor Desk** is a robust and intuitive mobile application developed using Flutter, meticulously designed to empower professionals. It provides a comprehensive suite of tools for efficiently managing daily tasks, monitoring performance metrics, and accurately calculating monthly earnings. With a strong emphasis on a clean user interface and practical functionalities, this app serves as an indispensable tool for users to maintain organization, boost motivation, and achieve their targets.

## 🚀 Features

This application is packed with features engineered for seamless and efficient performance tracking:

-   **Daily Entry Management:** Effortlessly add, edit, or delete daily work entries, including detailed login hours and call counts.
-   **Comprehensive Monthly Summaries:** Gain clear insights into monthly performance with automatically calculated totals, averages, and key metrics.
-   **Automated Salary Calculation:** Instantly calculates estimated monthly salary, incorporating:
    -   **Base Salary:** Based on call volume.
    -   **Performance Bonus:** Achieved through predefined criteria (e.g., calls and login hours targets).
    -   **CSAT Bonus:** Additional incentives based on CSAT scores and call volume targets.
    -   **TDS Deduction:** Automatic calculation of Tax Deducted at Source.
    -   **Net Salary:** Your final estimated take-home pay.
-   **Goal Setting & Tracking:** Set personalized monthly goals for login hours and calls, with progress vividly visualized through intuitive circular progress bars.
-   **Professional Report Generation:** Generate and share detailed monthly reports in:
    -   **PDF Format:** Comprehensive, well-structured PDF documents for easy viewing and sharing.
    -   **Excel Format:** Detailed Excel spreadsheets for in-depth analysis and record-keeping.
-   **Adaptive Theming:** Enjoy a beautifully crafted, theme-aware UI that seamlessly supports both light and dark modes, complete with a smooth animated switcher.
-   **Intuitive Navigation:** Navigate effortlessly between Dashboard, Monthly Performance, and Reports screens using fluid swipe gestures.
-   **Optimized Performance:** Experience rapid startup times with a professional native splash screen, and enjoy smooth scrolling and instant data retrieval for previously viewed months thanks to lazy loading and intelligent caching.
-   **Offline-First Capability:** All data is securely stored locally on the device using SQFlite, ensuring uninterrupted access and functionality anytime, anywhere, without an internet connection.
-   **Detailed App Information:** An accessible section providing essential information about the app and its developer.
-   **Direct Feedback Channel:** Easily send feedback directly from the app, with automatically included system information for efficient debugging.

## 🛠️ Tech Stack & Architecture

This project is built using cutting-edge technologies and adheres to a clean architecture pattern, specifically the BLoC (Business Logic Component) pattern for robust state management.

-   **Framework:** Flutter
-   **Language:** Dart
-   **Architecture:** BLoC (Business Logic Component) for State Management
-   **Local Database:** SQFlite
-   **Key Packages:**
    -   `flutter_bloc`: For predictable and scalable state management.
    -   `equatable`: Simplifies value equality checks for BLoC states.
    -   `sqflite` & `path_provider`: Facilitates local database operations and file system access.
    -   `intl`: Provides internationalization and date/number formatting capabilities.
    -   `fl_chart`: Enables the creation of beautiful and customizable charts.
    -   `shared_preferences`: For persisting simple key-value data.
    -   `google_fonts`: Integrates custom Google Fonts for enhanced typography.
    -   `permission_handler`: Streamlines runtime permission requests.
    -   `open_file`: Allows opening files directly from the app.
    -   `device_info_plus`: Gathers detailed device information.
    -   `pdf`: Powers the generation of high-quality PDF reports.
    -   `share_plus`: Provides native sharing capabilities for content.
    -   `shimmer`: Implements elegant loading animations.
    -   `percent_indicator`: Used for visually representing progress with circular indicators.
    -   `url_launcher`: For launching URLs, emails, and other schemes.

## 🚀 Installation & Usage

To get a local copy of the project up and running for development or testing, follow these simple steps:

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured.
-   A code editor such as [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/).

### Steps

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

## 📸 Screenshots

*(Placeholder: Add screenshots or a GIF of the app's key screens here to give users a visual overview.)*

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. Don't forget to give the project a star! Thanks again!

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

-   Special thanks to **Di Bhai (Mouma)** and **Sudhanshu** for rigorous testing and invaluable feedback.
-   To everyone else who contributed and made this project possible.
