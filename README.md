# Vantage Finance

[![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Clean--Pattern-green)](#architecture)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Vantage Finance** is a premium personal wealth management solution built with Flutter. It combines a minimalist aesthetic with powerful financial tracking capabilities, featuring integrated AI-driven insights to help users gain a strategic perspective on their financial health.

## 🚀 Key Features

- **Strategic Wealth Tracking**: Manage multiple wallets across different currencies with real-time exchange rate normalization.
- **Smart Budgeting**: Precision category-based budgeting with advanced progress visualization and multi-tier alerting (80% / 100% usage).
- **Vantage AI Assistant**: An integrated financial consultant powered by Google Gemini (via OpenRouter), capable of analyzing transaction history and providing proactive financial advice.
- **Deep Analytics**: Time-series data visualization for income vs. expenses and category-wise breakdown.
- **Enterprise-Grade Data Portability**: Standardized CSV export functionality for offline financial auditing.
- **Real-time Notifications**: Persistent alert system stored in Firestore for cross-device notification history.

## 🏗 Architecture

The project follows the principles of **Clean Architecture** and **Domain-Driven Design (DDD)** to ensure scalability, testability, and maintainability:

- **Core**: Shared utilities, global themes, and foundational widgets.
- **Features**: Modularized feature folders (Auth, Transaction, Budget, etc.), each containing:
  - `Domain`: Pure business logic, entities, and repository interfaces.
  - `Data`: DTOs, Mappers, and concrete Repository implementations.
  - `Application`: Services that orchestrate business rules.
  - `Presentation`: UI components and Riverpod state management.

## 🛠 Tech Stack

- **State Management**: [Flutter Riverpod](https://riverpod.dev/) (Reactive caching and state binding).
- **Database & Backend**: Firebase (Auth, Firestore, Cloud Storage).
- **Charts**: [FL Chart](https://pub.dev/packages/fl_chart).
- **Animations**: [Flutter Animate](https://pub.dev/packages/flutter_animate).
- **AI**: OpenRouter API with DeepSeek/Gemini models.

## 🏁 Getting Started

### Prerequisites

- Flutter SDK ^3.11.1
- Firebase Project setup

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Mufid-031/finance_management.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application with your API Key:
   ```bash
   flutter run --dart-define=OPENROUTER_API_KEY=your_key_here
   ```

---

Designed and developed by **MUFIDD LV 999**.
