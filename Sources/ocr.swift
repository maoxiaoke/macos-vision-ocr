import Cocoa
import Vision
import ArgumentParser
import Foundation

@main
struct MacOSVisionOCR: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ocr",
        abstract: "Perform OCR on single image or batch of images"
    )

    @Argument(help: "Image file path(s) to process")
    var inputFiles: [String] = []

    @Option(name: .long, help: "Path to a single image file")
    var img: String?

    @Option(name: .long, help: "Output directory for single image mode")
    var output: String?

    @Option(name: .long, help: "Directory containing images for batch mode")
    var imgDir: String?

    @Option(name: .long, help: "Output directory for batch mode")
    var outputDir: String?

    @Flag(name: .long, help: "Merge all text outputs into a single file in batch mode")
    var merge = false

    @Flag(name: .long, help: "Debug mode: Draw bounding boxes on the image")
    var debug = false

    @Flag(name: [.short, .long], help: "Output only the recognized text")
    var text = false

    @Flag(name: .long, help: "Show supported recognition languages")
    var lang = false

    @Option(name: .long, help: "Recognition languages (auto-detected if not specified)")
    var recLangs: String?

    var revision: Int {
        var REVISION: Int
        if #available(macOS 13, *) {
            REVISION = VNRecognizeTextRequestRevision3
        } else if #available(macOS 11, *) {
            REVISION = VNRecognizeTextRequestRevision2
        } else {
            REVISION = VNRecognizeAnimalsRequestRevision1
        }
        return REVISION
    }
    
    private func isEmptyBox(_ box: VNRectangleObservation) -> Bool {
        let width = box.topRight.x - box.topLeft.x
        let height = box.topLeft.y - box.bottomLeft.y
        return width * height == 0
    }
    
    private func extractSubBounds(imageRef: CGImage, observation: VNRecognizedTextObservation, recognizedText: VNRecognizedText, positionalJson: inout [[String: Any]]) {
        func normalizeCoordinate(_ value: CGFloat) -> CGFloat {
            return max(0, min(1, value))
        }

        let text = recognizedText.string
        let topLeft = observation.topLeft
        let topRight = observation.topRight
        let bottomRight = observation.bottomRight
        let bottomLeft = observation.bottomLeft

        let quad: [String: Any] = [
            "topLeft": [
                "x": normalizeCoordinate(topLeft.x),
                "y": normalizeCoordinate(1 - topLeft.y)
            ],
            "topRight": [
                "x": normalizeCoordinate(topRight.x),
                "y": normalizeCoordinate(1 - topRight.y)
            ],
            "bottomRight": [
                "x": normalizeCoordinate(bottomRight.x),
                "y": normalizeCoordinate(1 - bottomRight.y)
            ],
            "bottomLeft": [
                "x": normalizeCoordinate(bottomLeft.x),
                "y": normalizeCoordinate(1 - bottomLeft.y)
            ]
        ]

        positionalJson.append([
            "text": text,
            "confidence": observation.confidence,
            "quad": quad
        ])
    }
    
    private func getSupportedLanguages() -> [String] {
        if #available(macOS 13, *) {
            let request = VNRecognizeTextRequest()
            do {
                return try request.supportedRecognitionLanguages()
            } catch {
                return ["zh-Hans", "zh-Hant", "en-US", "ja-JP"]
            }
        } else {
            return ["zh-Hans", "zh-Hant", "en-US", "ja-JP"]
        }
    }
    
    mutating func run() throws {
        if lang {
            let languages = getSupportedLanguages()
            print("Supported recognition languages:")
            languages.forEach { print("- \($0)") }
            return
        }

        // Support positional arguments: ocr image.png or ocr a.png b.png
        if !inputFiles.isEmpty {
            if inputFiles.count == 1 {
                try processSingleImage(inputFiles[0], outputDir: output)
            } else {
                for file in inputFiles {
                    try processSingleImage(file, outputDir: output)
                }
            }
        } else if let img = img {
            try processSingleImage(img, outputDir: output)
        } else if let imgDir = imgDir {
            try processBatchImages(imgDir, outputDir: outputDir)
        } else {
            throw ValidationError("Provide image path(s) or use --img / --img-dir")
        }
    }

    private func processSingleImage(_ imagePath: String, outputDir: String?) throws {
        let result = try extractText(from: imagePath)

        if let outputDir = outputDir {
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: outputDir) {
                try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
            }
            let inputFileName = (imagePath as NSString).lastPathComponent
            let ext = text ? ".txt" : ".json"
            let outputFileName = (inputFileName as NSString).deletingPathExtension + ext
            let outputPath = (outputDir as NSString).appendingPathComponent(outputFileName)
            let content = text ? result.text : result.json
            try content.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("OCR result saved to: \(outputPath)")
        } else {
            print(text ? result.text : result.json)
        }

        if debug {
            try drawDebugImage(imagePath: imagePath, jsonResult: result.json)
        }
    }

    private func processBatchImages(_ imgDir: String, outputDir: String?) throws {
        let fileManager = FileManager.default
        
        if let outputDir = outputDir {
            if !fileManager.fileExists(atPath: outputDir) {
                try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
            }
        }

        let enumerator = fileManager.enumerator(atPath: imgDir)
        var imageFiles: [String] = []

        while let filePath = enumerator?.nextObject() as? String {
            if isImageFile(filePath) {
                imageFiles.append(filePath)
            }
        }

        imageFiles.sort()
        var mergedText = ""

        for imagePath in imageFiles {
            let fullImagePath = (imgDir as NSString).appendingPathComponent(imagePath)
            let result = try extractText(from: fullImagePath)

            if let outputDir = outputDir {
                let ext = text ? ".txt" : ".json"
                let outputPath = (outputDir as NSString).appendingPathComponent((imagePath as NSString).lastPathComponent + ext)
                let content = text ? result.text : result.json
                try content.write(toFile: outputPath, atomically: true, encoding: .utf8)
            }

            if merge {
                mergedText += result.text + "\n\n"
            }

            if debug {
                try drawDebugImage(imagePath: fullImagePath, jsonResult: result.json)
            }
        }

        if merge, let outputDir = outputDir {
            let mergedPath = (outputDir as NSString).appendingPathComponent("merged_output.txt")
            try mergedText.write(toFile: mergedPath, atomically: true, encoding: .utf8)
        }
    }

    private func isImageFile(_ filePath: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "webp"]
        return imageExtensions.contains((filePath as NSString).pathExtension.lowercased())
    }

    private func extractText(from imagePath: String) throws -> OCRResult {
        guard let img = NSImage(byReferencingFile: imagePath) else {
            throw OCRError.imageLoadFailed(path: imagePath)
        }

        guard let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw OCRError.imageConversionFailed(path: imagePath)
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        if let recLangs = recLangs {
            // Use explicitly specified languages
            let languages = recLangs
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            request.recognitionLanguages = languages
        } else if #available(macOS 13, *) {
            // Auto-detect language on macOS 13+
            request.automaticallyDetectsLanguage = true
        } else {
            request.recognitionLanguages = getSupportedLanguages()
        }

        request.revision = revision

        request.minimumTextHeight = 0.01

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        guard let observations = request.results else {
            throw OCRError.noTextFound
        }

        var positionalJson: [[String: Any]] = []
        var fullText: [String] = []

        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            fullText.append(candidate.string)
            extractSubBounds(imageRef: cgImage, observation: observation, recognizedText: candidate, positionalJson: &positionalJson)
        }

        let combinedFullText = fullText.joined(separator: "\n")

        let fileManager = FileManager.default
        let absolutePath = (fileManager.currentDirectoryPath as NSString).appendingPathComponent(imagePath)

        let info: [String: Any] = [
            "filename": (imagePath as NSString).lastPathComponent,
            "filepath": absolutePath,
            "width": cgImage.width,
            "height": cgImage.height
        ]

        let result: [String: Any] = [
            "info": info,
            "observations": positionalJson,
            "texts": combinedFullText
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
        return OCRResult(text: combinedFullText, json: jsonString)
    }

    private func drawDebugImage(imagePath: String, jsonResult: String) throws {
        guard let image = NSImage(contentsOfFile: imagePath) else {
            throw OCRError.imageLoadFailed(path: imagePath)
        }
        
        let size = image.size
        let imageRect = CGRect(origin: .zero, size: size)
        
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        
        // Draw original image
        image.draw(in: imageRect)
        
        // Parse JSON result
        guard let data = jsonResult.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let observations = json["observations"] as? [[String: Any]] else {
            throw OCRError.jsonParsingFailed
        }
        
        // Set up drawing context
        NSColor.red.setStroke()
        let context = NSGraphicsContext.current!.cgContext
        context.setLineWidth(1.0)
        
        // Draw quadrilaterals
        for observation in observations {
            guard let quad = observation["quad"] as? [String: [String: CGFloat]] else { continue }
            
            let topLeft = CGPoint(x: quad["topLeft"]!["x"]! * size.width, y: (1 - quad["topLeft"]!["y"]!) * size.height)
            let topRight = CGPoint(x: quad["topRight"]!["x"]! * size.width, y: (1 - quad["topRight"]!["y"]!) * size.height)
            let bottomRight = CGPoint(x: quad["bottomRight"]!["x"]! * size.width, y: (1 - quad["bottomRight"]!["y"]!) * size.height)
            let bottomLeft = CGPoint(x: quad["bottomLeft"]!["x"]! * size.width, y: (1 - quad["bottomLeft"]!["y"]!) * size.height)
            
            context.beginPath()
            context.move(to: topLeft)
            context.addLine(to: topRight)
            context.addLine(to: bottomRight)
            context.addLine(to: bottomLeft)
            context.closePath()
            context.strokePath()
        }
        
        newImage.unlockFocus()
        
        // Save the new image
        let outputFileName = (imagePath as NSString).deletingPathExtension + "_boxes.png"
        guard let pngData = newImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: pngData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw OCRError.imageConversionFailed(path: outputFileName)
        }
        
        try pngData.write(to: URL(fileURLWithPath: outputFileName))
        print("Debug image saved to: \(outputFileName)")
    }
}

struct OCRResult {
    let text: String
    let json: String
}

enum OCRError: Error {
    case imageLoadFailed(path: String)
    case imageConversionFailed(path: String)
    case jsonParsingFailed
    case noTextFound
}
