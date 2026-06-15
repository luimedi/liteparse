# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-15

### Added
- Initial release
- `LiteParse.parse_file/2` for parsing documents from disk
- `LiteParse.parse_input/2` for parsing documents from in-memory binary data
- `LiteParse.Config` struct and options for configuring the parser
- Rustler NIF wrapping the LiteParse Rust library
