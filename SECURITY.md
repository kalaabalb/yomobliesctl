# Security Policy

## Supported Versions

The current admin branch is the supported line for active YoMobiles work.

## Reporting a Vulnerability

Do not open a public issue for sensitive security problems.

Instead:

- use GitHub Security Advisories if available for the repository, or
- contact the repository maintainer directly through the project's private communication channel

Please include:

- a short description of the issue
- the affected screen or service
- the observed impact
- reproduction steps if available

## Handling Secrets

- Never commit JWT secrets, API keys, keystores, or private backend credentials.
- Use environment variables and local `key.properties` files that remain untracked.
