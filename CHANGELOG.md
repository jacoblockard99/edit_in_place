# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- The ability to use parameterless middleware classes directly.
- Magic `*_field` methods to `Builder`.
- `Builder#scope`, an alias for `Builder#scoped`.
- `Builder#with_middlewares` to easily allow scoping a builder with middlewares.
- The ability to register and use middlewares by name.

## [0.1.0] - 2021-07-15
### Added
- The initial `edit_in_place` gem.

[Unreleased]: https://github.com/jacoblockard99/edit_in_place/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/jacoblockard99/edit_in_place/releases/tag/v0.1.0
