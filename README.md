# YoMobiles Admin

Flutter administration application for the YoMobiles e-commerce platform.

This repository contains the merchant-facing dashboard used to manage users, catalog content, products, orders, ratings, and payment verification.

## Who Uses It

- YoMobiles administrators and moderators
- staff members responsible for catalog and order operations

## Key Features

- admin authentication
- JWT session restore on startup
- dashboard summary views
- product management
- category and sub-category management
- brand management
- poster management
- variant type management
- order review and payment verification
- admin user management

## Technology Stack

- Flutter
- GetX for routing and lightweight state helpers
- Provider for app-wide data dependencies
- GetStorage for session persistence
- REST API integration through a shared HTTP layer
- Google Fonts, fl_chart, and cached_network_image for the dashboard UI

## Architecture

- `lib/core/data/` owns shared data loading
- `lib/models/` contains JSON-backed model classes
- `lib/services/` contains the shared HTTP layer and auth service
- `lib/screens/` contains feature screens and provider classes
- `lib/widgets/` and `lib/utility/` contain reusable UI and helpers

The current entry point is [`lib/main.dart`](lib/main.dart).

## Authentication and Security Model

- The app stores the admin JWT access token and user payload in `GetStorage`.
- Stored admin sessions are validated on startup by calling `/admin-users/profile`.
- Invalid or expired sessions are cleared automatically.
- Role separation is enforced through the backend's admin routes.
- Do not commit tokens, API keys, or private backend credentials.

## API and Integration Model

- The API base URL is provided through the `MAIN_URL` compile-time define.
- The default hosted backend URL is defined in [`lib/utility/constants.dart`](lib/utility/constants.dart).
- Local development can target a running backend with `--dart-define=MAIN_URL=http://127.0.0.1:3000`.
- The backend lives in the sibling repository [YoMobiles Backend](https://github.com/kalaabalb/ecommerce-backend-api).
- The customer storefront lives in the sibling repository [YoMobiles Client](https://github.com/kalaabalb/yomoblies).

## Screenshots and Demo Evidence

Admin screenshots are reserved under [`docs/screenshots/`](docs/screenshots/README.md).

Representative captures currently checked in:

- `docs/screenshots/admin/authentication/login.png`
- `docs/screenshots/admin/dashboard/dashboard.png`
- `docs/screenshots/admin/products/add_product.png`
- `docs/screenshots/admin/products/product_details_review.png`
- `docs/screenshots/admin/catalog/categories.png`
- `docs/screenshots/admin/catalog/subcategories.png`
- `docs/screenshots/admin/catalog/brands.png`
- `docs/screenshots/admin/catalog/posters.png`
- `docs/screenshots/admin/catalog/variant_types.png`
- `docs/screenshots/admin/orders/order_details.png`
- `docs/screenshots/admin/orders/payment_verification.png`
- `docs/screenshots/admin/users/add_admin_user.png`

## Local Setup

### Prerequisites

- Flutter SDK 3.3 or newer
- Dart 3
- A device, emulator, or desktop target supported by Flutter

### Setup

```bash
git clone <repo-url>
cd yomoblies_admin
flutter pub get
```

### Run

```bash
flutter run --dart-define=MAIN_URL=http://127.0.0.1:3000
```

## Configuration

- API base URL is provided through the `MAIN_URL` compile-time define.
- Admin sessions are stored in `GetStorage` as `auth_token` and `user_data`.
- Stored admin sessions are validated on startup by calling `/admin-users/profile`.
- Invalid or expired sessions are cleared automatically.

## Testing

```bash
flutter test
flutter analyze
flutter build apk --release
flutter build linux --release
```

The repository currently includes a basic boot test for the login screen.

## Deployment / Current Status

- Android release signing is configured through local, gitignored signing files documented in [`android/RELEASE_SIGNING.md`](android/RELEASE_SIGNING.md).
- Linux release builds currently pass locally.
- GitHub Actions runs format, analyze, and test on pushes and pull requests.

## Known Limitations

- The admin app still depends on the backend being reachable at the configured API base URL.
- Release signing requires local environment setup before a production build.
- The screenshot set is representative rather than exhaustive.

## Future Improvements

- Extend GitHub Actions with device/emulator coverage when it becomes useful.
- Capture final production screenshots for the admin dashboard.
- Expand integration tests around payment verification and user management flows.

## Contributing

- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Keep UI, documentation, and backend contract changes aligned across the YoMobiles repos.

## Security

- [`SECURITY.md`](SECURITY.md)

## License

MIT License. See [`LICENSE`](LICENSE).

## Author

YoMobiles project maintainer
