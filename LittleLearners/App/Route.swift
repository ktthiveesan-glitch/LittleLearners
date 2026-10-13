//
//  Route.swift
//  LittleLearners
//

import SwiftUI

/// Every screen the app can navigate to from Home.
/// Using an enum means the compiler checks that we only go to screens that exist.
enum Route: Hashable {
    /// The grid of letters or numbers for one category.
    case characterList(LearningCategory)
    /// The lesson screen for one letter or number.
    case lesson(LearningItem)
    /// The finger-tracing screen for one letter or number.
    case tracing(LearningItem)
    /// The drag-and-drop shapes game.
    case shapesGame
    /// The sticker book of earned badges.
    case rewards
    /// The locked area for parents and teachers.
    case parentArea
}

/// Holds the navigation path: the list of screens currently stacked on top of Home.
/// Views change `path` to move around, and the `NavigationStack` in `RootView` follows it.
@Observable
final class Router {
    /// The screens on top of Home, oldest first. Empty means Home is showing.
    var path: [Route] = []

    /// Opens a new screen on top of the current one.
    func push(_ route: Route) {
        path.append(route)
    }

    /// Goes back one screen.
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    /// Goes all the way back to Home.
    func popToRoot() {
        path.removeAll()
    }
}
