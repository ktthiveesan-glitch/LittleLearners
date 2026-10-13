//
//  GuidePathBuilder.swift
//  LittleLearners
//

import SwiftUI
import CoreText
import UIKit

/// Turns a character such as "A", "අ" or "10" into a SwiftUI `Path` (its outline).
/// The tracing screen draws this outline as the dotted guide, and the coverage check
/// uses the same outline to see how much of the character the child has drawn over.
enum GuidePathBuilder {
    /// How much of the canvas the character fills (70%), leaving a margin around it.
    private static let fillShare: CGFloat = 0.7

    /// Builds the outline of `text`, scaled and centred to fit inside `size`.
    static func path(for text: String, in size: CGSize) -> Path {
        guard size.width > 0, size.height > 0 else { return Path() }

        // 1. Ask Core Text to lay the text out. It picks the right font for each script
        //    (the system font has no Sinhala or Tamil letters, so iOS swaps in one that does).
        let font = UIFont.systemFont(ofSize: 100, weight: .bold)
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))

        // 2. Collect the outline of every glyph (drawn shape of a character) in the line.
        let outline = CGMutablePath()
        for run in CTLineGetGlyphRuns(line) as? [CTRun] ?? [] {
            let attributes = CTRunGetAttributes(run) as NSDictionary
            guard let runFont = attributes[kCTFontAttributeName] else { continue }

            let count = CTRunGetGlyphCount(run)
            var glyphs = [CGGlyph](repeating: 0, count: count)
            var positions = [CGPoint](repeating: .zero, count: count)
            // A range of length 0 means "all glyphs in the run".
            CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &glyphs)
            CTRunGetPositions(run, CFRange(location: 0, length: 0), &positions)

            for (glyph, position) in zip(glyphs, positions) {
                if let glyphOutline = CTFontCreatePathForGlyph(runFont as! CTFont, glyph, nil) {
                    outline.addPath(glyphOutline, transform: CGAffineTransform(translationX: position.x, y: position.y))
                }
            }
        }

        // 3. Scale the outline to fit the canvas and centre it.
        //    Core Text's y axis points up but SwiftUI's points down, so the y scale is negative (a flip).
        let bounds = outline.boundingBoxOfPath
        guard bounds.width > 0, bounds.height > 0 else { return Path() }
        let scale = min(size.width * fillShare / bounds.width, size.height * fillShare / bounds.height)
        let transform = CGAffineTransform(a: scale, b: 0, c: 0, d: -scale,
                                          tx: size.width / 2 - bounds.midX * scale,
                                          ty: size.height / 2 + bounds.midY * scale)
        return Path(outline).applying(transform)
    }
}

extension Path {
    /// Builds one path from the child's finger strokes. Each stroke is a list of points
    /// joined by lines; a single tap becomes a dot.
    init(strokes: [[CGPoint]]) {
        self.init()
        for stroke in strokes {
            guard let first = stroke.first else { continue }
            move(to: first)
            if stroke.count == 1 {
                addLine(to: first)
            } else {
                addLines(stroke)
            }
        }
    }
}
