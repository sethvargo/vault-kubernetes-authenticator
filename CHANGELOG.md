# Changelog

All notable changes to this project will be documented in this file.

## [0.4.0] - 2019-08-10

### Added
- Support for Vault namespaces

## [0.2.0] - 2019-02-19

### Added
- Run as non-root user (appuser:appgroup - 1001:1001)
- Token accessor and token path default to `/var/run/secrets/vaultproject.io` instead of `/`

### Changed
- Base image is now alpine instead of scratch to support non-root users

## [0.1.2]

### Added
- Changelog
