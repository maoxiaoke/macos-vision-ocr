---
name: ocr
description: Extract text from images using the `ocr` CLI tool (macOS Vision framework). Use this skill whenever the user wants to read text from an image, screenshot, photo, scan, or document image. Also use it when the user shares an image path and asks "what does this say", "extract the text", "OCR this", "read this screenshot", or needs to batch-process images for text extraction. Triggers on any mention of OCR, text recognition, or reading/extracting text from image files (png, jpg, jpeg, webp).
---

# OCR - Extract Text from Images

`ocr` is a macOS command-line tool that extracts text from images using Apple's Vision framework. It auto-detects languages (including CJK) and outputs plain text by default.

## Prerequisites

The tool must be installed. If `ocr` is not found, install it:

```bash
brew install maoxiaoke/tap/ocr
```

## Core Usage

### Plain text output (default)

```bash
ocr <image-path>
```

This is the most common case. Just pass the image path and get text back.

### Multiple images

```bash
ocr image1.png image2.jpg image3.webp
```

### JSON output with position data

Use `--json` when the user needs bounding box coordinates, confidence scores, or structured data for programmatic use:

```bash
ocr --json <image-path>
```

### Pipe-friendly

The plain text output works naturally with pipes:

```bash
ocr screenshot.png | pbcopy          # Copy to clipboard
ocr receipt.jpg | grep "Total"       # Search in results
ocr document.png >> notes.txt        # Append to file
```

## When to Use Each Flag

| Scenario | Command |
|----------|---------|
| User just wants the text | `ocr image.png` |
| User needs coordinates/positions | `ocr --json image.png` |
| User wants results saved to files | `ocr image.png --output ./results` |
| User has a folder of images | `ocr --img-dir ./images --output-dir ./output` |
| User wants one merged text file from many images | `ocr --img-dir ./images --output-dir ./output --merge` |
| User wants to see where text was detected visually | `ocr --debug image.png` |
| Non-Latin text is garbled (rare, auto-detection usually works) | `ocr --rec-langs "zh-Hans, ja-JP" image.png` |

## Language Detection

Languages are auto-detected on macOS 13+. Manual specification via `--rec-langs` is only needed if auto-detection produces poor results (uncommon). Supported: English, French, Italian, German, Spanish, Portuguese, Chinese (Simplified/Traditional), Cantonese, Korean, Japanese, Russian, Ukrainian, Thai, Vietnamese.

## Supported Formats

JPG, JPEG, PNG, WEBP.

## Example Workflows

**User shares a screenshot and asks what it says:**
```bash
ocr /path/to/screenshot.png
```

**User wants to digitize a folder of scanned documents:**
```bash
ocr --img-dir ./scans --output-dir ./text-output --merge
```

**User needs OCR data for a script or application:**
```bash
ocr --json photo.jpg
```
Returns JSON with `texts`, `info` (dimensions, path), and `observations` (per-line text, confidence, quad coordinates normalized 0-1).
