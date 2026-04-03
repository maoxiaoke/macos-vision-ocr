# Skill: OCR - Extract Text from Images

Use the `ocr` command-line tool to extract text from images on macOS. It uses Apple's Vision framework with automatic language detection.

## Prerequisites

Install via Homebrew:

```bash
brew install maoxiaoke/tap/ocr
```

## When to Use

- User asks to extract/read/recognize text from an image
- User shares a screenshot and wants the text content
- User needs to batch process images for text extraction
- User needs OCR with position/coordinate data

## Usage

### Extract text (default: plain text output)

```bash
ocr image.png
```

### Multiple images

```bash
ocr a.png b.png c.png
```

### JSON output with positions and confidence scores

```bash
ocr --json image.png
```

### Specify recognition languages

Languages are auto-detected on macOS 13+. Override manually if needed:

```bash
ocr --rec-langs "zh-Hans, en-US" image.png
```

### Batch processing

```bash
ocr --img-dir ./images --output-dir ./output
ocr --img-dir ./images --output-dir ./output --merge
```

### Save to file

```bash
ocr image.png --output ./results          # saves .txt
ocr --json image.png --output ./results   # saves .json
```

### Debug mode (visualize detected text regions)

```bash
ocr --debug image.png
```

## Examples

```bash
# Read text from a screenshot
ocr ~/Desktop/screenshot.png

# Get JSON with bounding boxes for programmatic use
ocr --json photo.jpg

# Process all images in a folder, merge into one text file
ocr --img-dir ./scans --output-dir ./output --merge

# OCR a Chinese document
ocr --rec-langs "zh-Hans" document.png
```

## Supported Formats

JPG, JPEG, PNG, WEBP

## Supported Languages

English, French, Italian, German, Spanish, Portuguese, Simplified Chinese, Traditional Chinese, Cantonese, Korean, Japanese, Russian, Ukrainian, Thai, Vietnamese.

## Tips

- Default output is plain text — pipe it directly: `ocr image.png | pbcopy`
- Use `--json` when you need coordinates or confidence scores
- On macOS 13+, language is auto-detected — no need to specify `--rec-langs` in most cases
- Use `--debug` to generate a visual overlay image showing where text was detected
