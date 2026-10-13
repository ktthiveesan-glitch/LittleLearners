//
//  BadgeSticker.swift
//  LittleLearners
//

import SwiftUI

/// One round sticker showing a badge's picture. It fills whatever square space it is given,
/// so the same view works small in the grid and big when enlarged.
/// A locked badge is grey and faded, with a small lock on it.
struct BadgeSticker: View {
    let badge: Badge
    /// True if the child has won this badge.
    let isEarned: Bool

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            ZStack {
                Circle()
                    .fill(Theme.card)
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
                Circle()
                    .stroke(isEarned ? Theme.secondary : Color.gray.opacity(0.4), lineWidth: side * 0.05)
                // The picture is sized from the sticker, so it grows with it.
                Text(badge.emoji)
                    .font(.system(size: side * 0.45))
                    .foregroundStyle(Theme.primary)
                    .grayscale(isEarned ? 0 : 1)
                    .opacity(isEarned ? 1 : 0.35)
                if !isEarned {
                    Image(systemName: "lock.fill")
                        .font(.system(size: side * 0.18))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .padding(side * 0.08)
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    HStack {
        BadgeSticker(badge: .firstStar, isEarned: true)
        BadgeSticker(badge: .sinhalaLetters, isEarned: false)
    }
    .padding()
    .background(Theme.background)
}
