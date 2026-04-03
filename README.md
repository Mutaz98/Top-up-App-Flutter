# UAE Phone Top-Up App

A Flutter application for managing UAE phone top-up beneficiaries and executing transactions, built with **Clean Architecture**, **Bloc** state management, **Hive** offline storage, and comprehensive unit tests.

---

## 📱 Features

- **Manage Beneficiaries** — Add, view, and delete up to 5 UAE phone numbers with nicknames (max 20 chars)
- **Top-Up Amounts** — AED 5, 10, 20, 30, 50, 75, 100 with a clear fee breakdown
- **Business Rules Enforced**:
  - AED 3 fee deducted per transaction
  - Unverified users: max AED 500/month per beneficiary
  - Verified users: max AED 1,000/month per beneficiary
  - Total monthly limit: AED 3,000 across all beneficiaries
  - Balance check includes the fee
- **Offline Support** — Hive cache + pending transaction queue synced on reconnect
- **Premium Dark UI** — Deep navy/teal theme with Poppins font and animated progress bars

---

## 🚀 Setup & Running

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Flutter version 3.38.9

### Install & Run

```bash
# Clone the repository
git clone https://github.com/Mutaz98/Top-up-App-Flutter.git
cd topup

# Install dependencies
flutter pub get

# Run the app
flutter run
```

The app targets **iOS, Android**.

---

## 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage



Test files are located in `test/features/**`.

---

## 🏗️ Architecture

The project follows **Clean Architecture** principles, organized by feature to ensure modularity, maintainability, and scalability.

### Project Structure

lib/
├── app/
│   ├── bloc/           # Global BlocObserver for state tracking
│   ├── di/             # GetIt dependency injection setup (injection_container.dart)
│   ├── router/         # GoRouter declarative navigation (app_router.dart, app_routes.dart)
│   ├── theme/          # Premium dark theme configuration (app_theme.dart)
│   └── app.dart        # Root Application widget
├── core/
│   ├── cache/          # Hive local storage & box initialization (hive_initializer.dart, hive_boxes.dart)
│   ├── constants/      # App-wide constants and business rules (app_constants.dart)
│   ├── errors/         # Custom failures and exceptions (exceptions.dart, failures.dart)
│   ├── network/        # API endpoints, connectivity services & HTTP clients (api_endpoints.dart, connectivity_service.dart, http_client.dart, mock_http_client.dart)
│   ├── usecases/       # Base UseCase interface (usecase.dart)
│   └── widgets/        # Shared presentation components (connectivity_banner.dart, custom_button.dart, custom_text_button.dart, custom_text_field.dart)
├── features/
│   ├── beneficiaries/  # Management of top-up recipients
│   │   ├── data/       # Repositories & Hive/Remote datasources
│   │   ├── domain/     # Entities, UseCases & Repository interfaces
│   │   └── presentation/ # Bloc, Pages & Feature-specific widgets
│   ├── topup/          # Transaction logic and payment flows
│   └── user/           # Profile and verification management
└── main.dart           # Application entry point

### Data Flow

The architecture implements a unidirectional data flow with three distinct layers per feature:

1.  **Domain Layer**: The heart of the feature, containing Business Logic (UseCases), Entities, and Repository Interfaces.
2.  **Data Layer**: Responsible for data retrieval, consisting of Repository implementations and Data Sources (Hive for local, HTTP for remote).
3.  **Presentation Layer**: The UI layer, utilizing **BLoC** for state management and functional components for the interface.

**Flow**: Presentation → UseCase (Domain) → Repository (Data) → DataSource (Remote/Local)

---

## 📐 Assumptions

1. **Mock HTTP Service** — The backend is mocked via `MockHttpClient` with 400ms simulated latency. It is pre-seeded with one user (`Ahmed Al Rashid`, balance AED 2,500) and two beneficiaries.

2. **Verification Toggle** — The user's verification status (`isVerified`) is toggled via a chip in the app bar for demonstration purposes. In production, this would come from the backend.

3. **Monthly Totals** — The current month's top-up totals for the user and each beneficiary are tracked in the mock and persisted locally in Hive. They are not reset automatically (a real backend would handle calendar-month resets).

4. **Offline Queue** — When offline, top-up transactions are queued in Hive's `pendingTopUpsBox` using a FIFO strategy. They are synced automatically when connectivity is restored (via `ConnectivityService` stream).

5. **Error Rollback** — Adding/deleting beneficiaries uses an optimistic local write. If the remote call subsequently fails, the UI shows an error but does not automatically rollback the local state (acceptable for a mock backend).

6. **UAE Phone Validation** — Accepts numbers in the format `+971 5X XXXXXXX`.

---

## 📦 Key Packages

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management (v9.1.1+) |
| `go_router` | Declarative routing (v17.2.0+) |
| `get_it` | Dependency injection (v9.2.1+) |
| `dartz` | Functional error handling (`Either`) |
| `hive_flutter` | Offline local storage |
| `connectivity_plus` | Network status monitoring |
| `google_fonts` | Poppins typography |
| `bloc_test` + `mocktail` | Unit testing |
