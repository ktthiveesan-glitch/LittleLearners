//
//  HandwritingRecognizer.swift
//  LittleLearners
//

import SwiftUI
import Vision

/// The outcome of checking one tracing.
struct TracingResult {
    /// True if the tracing was judged correct.
    let isCorrect: Bool
    /// How good it was, from 0.0 to 1.0 (Vision's confidence, or the coverage share).
    let score: Double
}

/// One possible reading of the drawing returned by Vision, with how sure Vision is (0.0 to 1.0).
nonisolated struct RecognizedText: Sendable {
    let text: String
    let confidence: Float
}

/// Decides whether the child's drawing matches the character they were asked to trace.
///
/// - English letters and digits: Apple's **Vision** framework (on-device machine learning)
///   reads the drawing like a scanner reads printed text.
/// - Sinhala and Tamil letters: Vision does NOT support these scripts, so the drawing is
///   checked by coverage instead (see `CoverageChecker`).
///
/// Honest limits: Vision is trained on words and sentences, not on one large letter drawn with
/// a finger. In our own trial with handwriting-style fonts it read a single letter correctly
/// only about 6 times in 10, and about 8 times in 10 once the letter was repeated three times
/// in a row (which looks more like a word). So when Vision cannot read an English letter or digit,
/// we fall back to the coverage check, so that a child who traced well is not told "try again".
final class HandwritingRecognizer {

    /// Checks the drawing against the expected item and returns the result.
    func check(strokes: [[CGPoint]], guide: Path, canvasSize: CGSize, lineWidth: CGFloat,
               item: LearningItem) async -> TracingResult {
        // English letters and digits: ask Vision first. If it reads the character, we are done.
        if Self.canVisionRead(item),
           let confidence = await visionConfidence(strokes: strokes, lineWidth: lineWidth, expected: item.character) {
            return TracingResult(isCorrect: true, score: confidence)
        }

        // Sinhala and Tamil (coverage is the only check we have), or Vision could not read it
        // (see "Honest limits" above): check by coverage.
        let coverage = CoverageChecker.check(strokes: strokes, guide: guide, canvasSize: canvasSize)
        return TracingResult(isCorrect: coverage.isPassing, score: coverage.coverage)
    }

    /// Vision can read English letters and digits only.
    static func canVisionRead(_ item: LearningItem) -> Bool {
        item.script == .english || item.category == .numbers
    }

    /// Returns Vision's confidence if it reads the drawing as `expected`, or `nil` if it does not.
    /// It tries a picture with three copies of the drawing first, then the single drawing.
    func visionConfidence(strokes: [[CGPoint]], lineWidth: CGFloat, expected: String) async -> Double? {
        for copies in [3, 1] {
            guard let image = renderImage(strokes: strokes, lineWidth: lineWidth, copies: copies) else { continue }
            let candidates = await Self.recognizeText(in: image)
            if let match = candidates.first(where: { Self.matches($0.text, expected: expected, copies: copies) }) {
                return Double(match.confidence)
            }
        }
        return nil
    }

    // MARK: - Step 1: turn the drawing into a picture

    /// Draws the strokes in black on white, `copies` times side by side, and returns the picture.
    /// `ImageRenderer` turns any SwiftUI view into an image.
    private func renderImage(strokes: [[CGPoint]], lineWidth: CGFloat, copies: Int) -> CGImage? {
        let single = Path(strokes: strokes)
        let bounds = single.boundingRect
        let unit = max(bounds.width, bounds.height, lineWidth)
        let margin = unit * 0.4 + lineWidth              // white space around the drawing
        let step = bounds.width + unit * 0.3 + lineWidth  // distance from one copy to the next

        var combined = Path()
        for copy in 0..<copies {
            let shift = CGAffineTransform(translationX: margin - bounds.minX + step * CGFloat(copy),
                                          y: margin - bounds.minY)
            combined.addPath(single, transform: shift)
        }

        let picture = combined
            .stroke(Color.black, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .frame(width: bounds.width + step * CGFloat(copies - 1) + margin * 2,
                   height: bounds.height + margin * 2)
            .background(Color.white)

        let renderer = ImageRenderer(content: picture)
        renderer.scale = 1
        return renderer.cgImage
    }

    // MARK: - Step 2: ask Vision to read the picture

    /// Runs Vision text recognition on the picture and returns everything it thinks the text could be.
    /// `@concurrent` makes this run in the background, so the screen does not freeze while Vision works.
    @concurrent
    nonisolated private static func recognizeText(in image: CGImage) async -> [RecognizedText] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate        // slower but better; needed for handwriting
        request.usesLanguageCorrection = false      // do not "fix" a single letter into a word
        request.recognitionLanguages = ["en-US"]

        let handler = VNImageRequestHandler(cgImage: image)
        do {
            try handler.perform([request])
        } catch {
            return []
        }

        // Each observation is one piece of text Vision found. For each, take its best five guesses.
        let observations = request.results ?? []
        return observations.flatMap { observation in
            observation.topCandidates(5).map { RecognizedText(text: $0.string, confidence: $0.confidence) }
        }
    }

    // MARK: - Step 3: compare what Vision read with what we expected

    /// Characters Vision often returns instead of the expected one because they look the same when hand-drawn.
    private static let lookalikes: [String: [Character]] = [
        "O": ["0"],
        "I": ["l", "1", "|"],
        "1": ["I", "l", "|"],
    ]

    /// Vision sometimes answers with Cyrillic letters that look identical to Latin ones. Map them back.
    private static let cyrillicToLatin: [Character: Character] = [
        "А": "A", "В": "B", "Е": "E", "К": "K", "М": "M", "Н": "H", "О": "O",
        "Р": "P", "С": "C", "Т": "T", "У": "Y", "Х": "X", "І": "I",
    ]

    /// True if `text` (what Vision read) counts as the expected character.
    /// The picture held `copies` copies, so the expected character must appear in more than half of them,
    /// and there must not be lots of extra text. Upper and lower case are treated the same.
    static func matches(_ text: String, expected: String, copies: Int) -> Bool {
        let swaps = lookalikes[expected] ?? []
        var cleaned = ""
        for character in text where !character.isWhitespace {
            if swaps.contains(character) {
                cleaned += expected
            } else {
                cleaned += String(cyrillicToLatin[character] ?? character).uppercased()
            }
        }
        let found = cleaned.components(separatedBy: expected.uppercased()).count - 1
        let longestAllowed = copies * expected.count + 1
        return found * 2 > copies && cleaned.count <= longestAllowed
    }
}
