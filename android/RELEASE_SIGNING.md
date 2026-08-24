# Android Release Signing

This project uses a local, gitignored release signing setup.

## Required files

- `android/key.properties`
- a local release keystore referenced by `storeFile`

## Setup

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Point `storeFile` at your local release keystore.
3. Fill in the keystore password, key alias, and key password.
4. Keep both files out of git.

## Example build

```bash
flutter build apk --release
```

## CI notes

For CI, inject the keystore and `key.properties` content from your secret store at build time.
Do not commit signing secrets into the repository.
