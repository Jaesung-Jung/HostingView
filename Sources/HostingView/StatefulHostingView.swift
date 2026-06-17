//
//  StatefulHostingView.swift
//
//  Copyright © 2024 Jaesung Jung. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI
import Combine

/// A hosting view that updates its SwiftUI content when its state changes.
///
/// Use a stateful hosting view when UIKit owns the source of truth for a value
/// that SwiftUI renders. The view passes the current state to the content
/// builder, publishes changes to SwiftUI, and invalidates its intrinsic content
/// size after each assignment.
///
/// The following example creates a view whose SwiftUI content depends on a
/// Boolean value:
///
/// ```swift
/// let favoriteView = StatefulHostingView(state: false) { isFavorite in
///   Label(
///     isFavorite ? "Favorite" : "Not Favorite",
///     systemImage: isFavorite ? "star.fill" : "star"
///   )
/// }
///
/// favoriteView.state = true
/// ```
///
/// Use the ``state`` property to send new values from UIKit into the hosted
/// SwiftUI hierarchy.
public final class StatefulHostingView<State>: HostingView {
  private let stateObject: StateObject

  /// The value that the view passes to its hosted SwiftUI content.
  ///
  /// Assigning a new value updates the SwiftUI hierarchy and invalidates the
  /// view's intrinsic content size. Use this property when UIKit events, model
  /// changes, or control state should drive the rendered SwiftUI content.
  public var state: State {
    get { stateObject.state }
    set {
      stateObject.state = newValue
      invalidateIntrinsicContentSize()
    }
  }

  /// Creates a stateful hosting view with the initial state and SwiftUI content
  /// that you provide.
  ///
  /// The content builder receives the current state value each time SwiftUI
  /// evaluates the hosted view hierarchy.
  ///
  /// - Parameters:
  ///   - state: The initial state value to pass to the hosted SwiftUI content.
  ///   - content: A view builder that creates the SwiftUI view hierarchy for a
  ///     given state value.
  public init<Content: View>(state: State, @ViewBuilder content: @escaping (State) -> Content) {
    let stateObject = StateObject(state: state)
    self.stateObject = stateObject
    super.init {
      StatefulContentView(stateObject: stateObject, content: content)
    }
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - StatefulHostingView.StatefulContentView

extension StatefulHostingView {
  struct StatefulContentView<Content: View>: View {
    @ObservedObject var stateObject: StateObject

    let content: (State) -> Content

    var body: some View {
      content(stateObject.state)
    }
  }
}

// MARK: - StatefulHostingView.StateObject

extension StatefulHostingView {
  final class StateObject: ObservableObject {
    @Published var state: State

    init(state: State) {
      self.state = state
    }
  }
}

// MARK: - StatefulHostingView Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  StatefulHostingView(state: Int.random(in: 0..<9)) { state in
    VStack {
      Text("Stateful Hosting View")
        .font(.headline)
        .fontWeight(.black)

      Text("State is \(state)")
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundStyle(.secondary)
    }
  }
}
