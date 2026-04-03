# ocr - macOS Vision OCR CLI

## Project Overview

A command-line OCR tool for macOS that uses Apple's Vision framework to extract text from images. Distributed via Homebrew (`brew install maoxiaoke/tap/ocr`) and curl install script.

## Tech Stack

- **Language**: Swift 5.9+
- **Build**: Swift Package Manager (`Package.swift`)
- **Dependencies**: Swift Argument Parser 1.2.3
- **Frameworks**: Vision, Cocoa, Foundation
- **CI/CD**: GitHub Actions (`.github/workflows/release.yml`)
- **Distribution**: Homebrew tap (`maoxiaoke/homebrew-tap`), curl install script

## Project Structure

```
Sources/ocr.swift        # All source code (single file)
Package.swift            # SPM config, target name is "ocr"
HomebrewFormula/ocr.rb   # Homebrew formula (template for tap repo)
install.sh               # curl one-line install script
scripts/update-formula.sh # Helper to update formula SHA256 after release
.github/workflows/release.yml # Release CI: builds arm64, x86_64, universal
```

## Key Design Decisions

- **Single source file**: All code is in `Sources/ocr.swift` — keep it that way unless complexity warrants splitting
- **Default output is plain text**, use `--json` for JSON with positions
- **Auto language detection** via `automaticallyDetectsLanguage` on macOS 13+ when `--rec-langs` not specified
- **Positional arguments**: `ocr image.png` works, no need for `--img` flag
- **Executable name is `ocr`**, not `macos-vision-ocr`

## Build & Test

```bash
swift build -c release --arch arm64    # Build
.build/release/ocr image.png           # Run
.build/release/ocr --json image.png    # JSON output
.build/release/ocr --lang              # List languages
```

## Release Process

1. Commit and push changes to `main`
2. Trigger release workflow:
   ```bash
   gh workflow run release.yml --field platform=all --field version=v<VERSION>
   ```
3. Wait for build to complete, then get SHA256:
   ```bash
   # Download and hash
   curl -sL -o /tmp/arm64.zip "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v<VERSION>/ocr-macos-arm64-v<VERSION>.zip"
   curl -sL -o /tmp/x86_64.zip "https://github.com/maoxiaoke/macos-vision-ocr/releases/download/v<VERSION>/ocr-macos-x86_64-v<VERSION>.zip"
   shasum -a 256 /tmp/arm64.zip /tmp/x86_64.zip
   ```
4. Update `HomebrewFormula/ocr.rb` with new version and SHA256
5. Push formula to both this repo AND `maoxiaoke/homebrew-tap` (clone at `/tmp/homebrew-tap`):
   ```bash
   cp HomebrewFormula/ocr.rb /tmp/homebrew-tap/Formula/ocr.rb
   cd /tmp/homebrew-tap && git add . && git commit -m "Update ocr to v<VERSION>" && git push
   ```

## CLI Options Reference

```
ocr [<input-files> ...] [options]

Positional:  <input-files>       Image file path(s)
Options:     --json              JSON output with positions
             --img <path>        Single image (legacy, prefer positional)
             --output <path>     Output directory (single mode)
             --img-dir <path>    Batch input directory
             --output-dir <path> Batch output directory
             --merge             Merge batch results into one file
             --debug             Draw bounding boxes
             --rec-langs <langs> Manual language list (comma-separated)
             --lang              Show supported languages
```
