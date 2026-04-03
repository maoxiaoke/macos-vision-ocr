# ocr

A macOS command-line OCR tool powered by Apple's Vision framework. Extracts text from images with automatic language detection.

## Quick Start

```bash
brew install maoxiaoke/tap/ocr

ocr photo.png
```

## Installation

### Homebrew (Recommended)

```bash
brew install maoxiaoke/tap/ocr
```

### Quick Install via curl

```bash
curl -fsSL https://raw.githubusercontent.com/maoxiaoke/macos-vision-ocr/main/install.sh | bash
```

### Build from Source

```bash
git clone https://github.com/maoxiaoke/macos-vision-ocr.git
cd macos-vision-ocr
swift build -c release --arch arm64   # Apple Silicon
# swift build -c release --arch x86_64  # Intel
cp .build/release/ocr /usr/local/bin/ocr
```

## Usage

### Basic Usage

```bash
# Extract text from an image (outputs plain text by default)
ocr image.png

# Multiple images
ocr a.png b.png c.png

# Output as JSON with position data
ocr --json image.png
```

### Output to File

```bash
# Save result to a directory
ocr image.png --output ./results

# JSON output to file
ocr --json image.png --output ./results
```

### Batch Processing

```bash
# Process all images in a directory
ocr --img-dir ./images --output-dir ./output

# Merge all results into a single text file
ocr --img-dir ./images --output-dir ./output --merge
```

### Language Options

Languages are auto-detected on macOS 13+. You can also specify manually:

```bash
ocr image.png --rec-langs "zh-Hans, en-US"

# Show all supported languages
ocr --lang
```

### Debug Mode

Generates an annotated image with red bounding boxes around detected text:

```bash
ocr image.png --debug
```

![handwriting_boxes.png](./images/handwriting_boxes.png)

### All Options

```
USAGE: ocr [<input-files> ...] [options]

ARGUMENTS:
  <input-files>           Image file path(s) to process

OPTIONS:
  --json                  Output as JSON with position data
  --img <path>            Path to a single image file
  --output <path>         Output directory for single image mode
  --img-dir <path>        Directory containing images for batch mode
  --output-dir <path>     Output directory for batch mode
  --merge                 Merge all text outputs into a single file
  --debug                 Draw bounding boxes on the image
  --rec-langs <langs>     Recognition languages (auto-detected if not specified)
  --lang                  Show supported recognition languages
  -h, --help              Show help information
```

## JSON Output Format

When using `--json`, the output includes text positions and confidence scores:

```json
{
  "texts": "Detected text content...",
  "info": {
    "filepath": "./images/handwriting.webp",
    "filename": "handwriting.webp",
    "width": 1600,
    "height": 720
  },
  "observations": [
    {
      "text": "Detected line of text",
      "confidence": 0.95,
      "quad": {
        "topLeft": { "x": 0.09, "y": 0.28 },
        "topRight": { "x": 0.88, "y": 0.28 },
        "bottomRight": { "x": 0.88, "y": 0.35 },
        "bottomLeft": { "x": 0.09, "y": 0.35 }
      }
    }
  ]
}
```

## Supported Languages

English, French, Italian, German, Spanish, Portuguese (Brazil), Simplified Chinese, Traditional Chinese, Simplified Cantonese, Traditional Cantonese, Korean, Japanese, Russian, Ukrainian, Thai, Vietnamese.

## Node.js Integration

```javascript
const { execSync } = require("child_process");

// Plain text
const text = execSync('ocr image.png').toString();

// JSON with positions
const json = JSON.parse(execSync('ocr --json image.png').toString());
console.log(json.texts);
console.log(json.observations);
```

## System Requirements

- macOS 10.15+ (macOS 13+ recommended for auto language detection)
- arm64 (Apple Silicon) or x86_64 (Intel)

## Uninstall

```bash
# Homebrew
brew uninstall ocr

# curl install
rm /usr/local/bin/ocr
```

## License

MIT License - see [LICENSE](LICENSE) for details.
