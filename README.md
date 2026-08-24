# YoMobiles Admin

Flutter administration application for the YoMobiles e-commerce platform.

This repository contains the merchant-facing dashboard used to manage users, catalog content, products, orders, ratings, and payment verification.

## Stack

- Flutter
- GetX for routing and state helpers
- Provider for app-wide data dependencies
- GetStorage for session persistence
- REST API integration through a shared HTTP layer
- Google Fonts, fl_chart, and cached_network_image for the dashboard UI

## Features

- Admin authentication
- Session restore from stored JWT access token
- Dashboard summary views
- Product management
- Category and sub-category management
- Brand management
- Poster management
- Variant type management
- Order review and payment verification
- Admin user management

## Screenshots

Production screenshots are organized under [`docs/screenshots/`](docs/screenshots/README.md):

- `admin/authentication/login.png`
- `admin/dashboard/dashboard.png`
- `admin/products/add_product.png`
- `admin/products/product_details_review.png`
- `admin/catalog/categories.png`
- `admin/orders/order_details.png`
- `admin/orders/payment_verification.png`
- `admin/users/add_admin_user.png`

## Installation

### Prerequisites

- Flutter SDK 3.3 or newer
- Dart 3
- A device or desktop target supported by Flutter

### Setup

```bash
git clone <repo-url>
cd yomoblies_admin
flutter pub get
```

### Run

By default the app uses the hosted backend URL declared in [`lib/utility/constants.dart`](lib/utility/constants.dart).

For local development against a running backend, override the API base URL at launch:

```bash
flutter run --dart-define=MAIN_URL=http://127.0.0.1:3000
```

## Configuration

- API base URL is provided through the `MAIN_URL` compile-time define.
- Admin sessions are stored in `GetStorage` as `auth_token` and `user_data`.
- Stored admin sessions are validated on startup by calling `/admin-users/profile`.
- Invalid or expired sessions are cleared automatically.

## Architecture

The admin app is organized around a feature-oriented Flutter structure:

- `lib/core/data/` owns shared data loading
- `lib/models/` contains JSON-backed model classes
- `lib/services/` contains the shared HTTP layer and auth service
- `lib/screens/` contains feature screens and provider classes
- `lib/widgets/` and `lib/utility/` contain reusable UI and helpers

The current entry point is [`lib/main.dart`](lib/main.dart).

## Backend Repository

The backend lives in the sibling repository [`../yomobiles_backend`](../yomobiles_backend).

It is responsible for authentication, data validation, catalog state, orders, ratings, and payment verification.

## API Documentation

The admin app uses the same backend API as the client app, but with admin-protected routes such as:

- `/admin-users/login`
- `/admin-users/profile`
- `/orders`
- `/orders/:id/verify-payment`
- `/payment/verify-payment/:orderId`

## Testing

```bash
flutter test
flutter analyze
```

The repository currently includes a basic boot test for the login screen.

## Contributing

Review the shared backend contract before making changes to admin flows. Keep UI and API behavior aligned with the client app.

## Security

Do not commit tokens, API keys, or private backend credentials.

## License

MIT License. See [`LICENSE`](LICENSE).

## Author

YoMobiles project maintainer
