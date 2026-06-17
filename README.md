<p align="center">
<img src="https://img.shields.io/badge/platforms-iOS%2016%2B%20%7C%20macCatalyst%2016%2B%20%7C%20tvOS%2016%2B%20%7C%20visionOS%201%2B-333333.svg" alt="Supported platforms: iOS 16+, macCatalyst 16+, tvOS 16+, visionOS 1+" />
<br />
<a href="https://github.com/swiftlang/swift-package-manager" title="Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="Swift Package Manager compatible" /></a>
</p>

# HostingView

`HostingView` makes it straightforward to place SwiftUI views inside a UIKit
view hierarchy.

SwiftUI and UIKit work well together, but embedding SwiftUI in UIKit often means
managing a `UIHostingController` or adapting `UIHostingConfiguration` outside of
the cell APIs it was designed for. This package provides small `UIView`
subclasses that host SwiftUI content while participating naturally in Auto
Layout.

## Features

- Host SwiftUI content directly in a `UIView`.
- Measure hosted content through Auto Layout and `intrinsicContentSize`.
- Update SwiftUI content from UIKit state changes.
- Build UIKit custom views and controls with SwiftUI rendering code.

## Interaction and sizing

For the most predictable layout behavior, use `HostingView` for SwiftUI content
that does not handle user interaction directly.

UIKit should usually own user actions, control state, and event handling. Let
SwiftUI render the current state, and update that state from UIKit by assigning
to `StatefulHostingView.state`.

Avoid placing interactive SwiftUI controls inside a hosting view when those
interactions can change the hosted content's size. SwiftUI interactions that
mutate internal state and resize the view may cause intrinsic content size
updates to arrive at times that are difficult for UIKit's layout system to
reconcile.

The recommended pattern is:

- Handle taps, gestures, target-action, and accessibility behavior in UIKit.
- Render the visual state with SwiftUI.
- Use `StatefulHostingView` when UIKit needs to send state changes into SwiftUI.
- Prefer noninteractive SwiftUI content when using `HostingView`.

## When to use HostingView

Use `HostingView` when the SwiftUI content is created once and does not need an
external state value from UIKit. It works best for visual content that does not
own user interaction.

```swift
import SwiftUI
import HostingView

let titleView = HostingView {
  Text("Hosting View")
    .font(.largeTitle)
    .fontWeight(.black)
    .foregroundStyle(
      .linearGradient(
        colors: [.cyan, .indigo, .pink, .orange, .yellow],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
}

view.addSubview(titleView)
titleView.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
  titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
  titleView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
])
```

The hosting view invalidates its intrinsic content size when the SwiftUI
content changes size, so UIKit can measure it again during layout.

## When to use StatefulHostingView

Use `StatefulHostingView<State>` when UIKit owns a value and SwiftUI renders a
view from that value. Assigning a new value to `state` publishes the update to
SwiftUI and invalidates the hosting view's intrinsic content size.

```swift
import SwiftUI
import HostingView

let favoriteView = StatefulHostingView(state: false) { isFavorite in
  Label(
    isFavorite ? "Favorite" : "Not Favorite",
    systemImage: isFavorite ? "star.fill" : "star"
  )
  .font(.headline)
  .foregroundStyle(isFavorite ? .yellow : .secondary)
}

favoriteView.state = true
```

`StatefulHostingView` is especially useful for custom UIKit controls. A control
can keep touch handling, target-action, and accessibility behavior in UIKit
while rendering its visual state with SwiftUI.

```swift
final class FavoriteButton: UIControl {
  private let contentView = StatefulHostingView(state: false) { isSelected in
    Image(systemName: isSelected ? "star.fill" : "star")
      .foregroundStyle(isSelected ? .yellow : .secondary)
      .font(.title2)
      .frame(width: 44, height: 44)
  }

  override var intrinsicContentSize: CGSize {
    contentView.intrinsicContentSize
  }

  override var isSelected: Bool {
    didSet {
      contentView.state = isSelected
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.isUserInteractionEnabled = false
    addSubview(contentView)

    addAction(UIAction { [weak self] _ in
      self?.isSelected.toggle()
      self?.sendActions(for: .valueChanged)
    }, for: .touchUpInside)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
  }
}
```

For more examples, see the [Demo](Demo) project.

## Requirements

- iOS 16+
- macCatalyst 16+
- tvOS 16+
- visionOS 1+

## Installation

### Swift Package Manager

Add `HostingView` as a package dependency:

```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(url: "https://github.com/Jaesung-Jung/HostingView.git", .upToNextMajor(from: "2.0"))
  ],
  targets: [
    .target(
      name: "YourProject",
      dependencies: [
        .product(name: "HostingView", package: "HostingView")
      ]
    )
  ]
)
```

Then import the package where you want to host SwiftUI content:

```swift
import HostingView
```

## License

HostingView is available under the MIT license. See [LICENSE](LICENSE) for
details.
