# capytool

A CLI tool for dotfiles management.

## Build

```bash
make build-tools
```

## Test

```bash
make test-tools
```

## Install

```bash
make install-tools
```

This will install `capytool` to `~/bin/`.

## Usage

```bash
capytool --version
```

## Release

To create a new release, push a tag with the format `capytool-v*`:

```bash
git tag capytool-v0.1.0
git push origin capytool-v0.1.0
```

GitHub Actions will automatically build and release binaries for:
- Linux (AMD64, ARM64)
- macOS (AMD64, ARM64)
