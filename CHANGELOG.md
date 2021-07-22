# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- A bug where middlewares were not properly represented in error messages.

## [0.2.0] - 2021-07-18
### Added
- The ability to use parameterless field type classes directly.
- The ability to use parameterless middleware classes directly.
- Magic `*_field` methods to `Builder`.
- `Builder#scope`, an alias for `Builder#scoped`.
- `Builder#with_middlewares` to easily allow scoping a builder with middlewares.
- The ability to register and use middlewares by name.
### Changed
- Changed `Builder#field` to pass the mode, not the field options, as the first argument. `FieldOptions` now represents options specifically for the `Builder#field` method.
- Removed 'rails' depedency, effectively making `edit_in_place` a plain Ruby gem.
### Removed
- Removed the view context from `FieldOptions`. Applications are now in charge themselves of managing the view context.
### Fixed
- A bug where duplicated `FieldTypeRegistrar` and `MiddlewareTypeRegistrar` instances became `Registrar` instances.

## [0.1.0] - 2021-07-15
### Added
- The initial `edit_in_place` gem.

[Unreleased]: https://github.com/jacoblockard99/edit_in_place/compare/v0.2.0...HEAD
[0.1.0]: https://github.com/jacoblockard99/edit_in_place/releases/tag/v0.1.0
[0.2.0]: https://github.com/jacoblockard99/edit_in_place/releases/tag/v0.2.0
