# Contributing

Thanks for improving YoMobiles Admin.

## Before You Change Code

- Read [`README.md`](README.md) and [`pubspec.yaml`](pubspec.yaml).
- Keep admin role behavior, API contracts, and release signing assumptions stable unless a change is explicitly requested.
- Do not commit secrets, tokens, or local environment files.

## Recommended Workflow

1. Create a feature branch.
2. Make the smallest change that solves the problem.
3. Add or update tests when behavior changes.
4. Run:
   - `flutter analyze`
   - `flutter test`
5. Update documentation when the UI or backend contract changes.

## Pull Requests

- Explain what changed and why.
- Link the issue or task if one exists.
- Call out any migration or environment changes.

## Style

- Prefer small, focused commits.
- Keep feature screens and providers aligned with the current folder structure.
