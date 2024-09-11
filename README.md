<p align="center">
<img src="https://img.shields.io/badge/platforms-iOS 16+%20%7C%20macCatalyst 16+%20%7C%20tvOS 16+-333333.svg" alt="Supported Platforms: iOS, macCatalyst and tvOS" />
<br />
<a href="https://github.com/swiftlang/swift-package-manager" alt="RxSwift on Swift Package Manager" title="RxSwift on Swift Package Manager"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" /></a>
</p>

# HostingView

SwiftUI is Apple's modern UI framework. While SwiftUI has come a long way since it was first released, it still lacks the ability to fully control every UI element in great detail, which is why many developers still use UIKit or partially use SwiftUI.

Apple provides a way to integrate UIKit and SwiftUI, but using the `UIHostingController` within the `UIView` hierarchy can be a bit cumbersome.

In iOS 16, Apple introduced `UIHostingConfiguration` as a new way to integrate SwiftUI with UICollectionViewCell and UITableViewCell. Inspired by this, I created `HostingView`.

This package provides two ways to integrate SwiftUI: `HostingView` and `StatefulHostingView<State>`.

## HostingView
You can wrap a stateless SwiftUI view.
```swift
let gradientText = HostingView {
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
```
The `intrinsicContentSize` is also correctly calculated, ensuring that the view behaves appropriately according to the size provided by the SwiftUI view.

## StatefulHostingView
You can wrap a stateful SwiftUI view, and SwiftUI will re-render the view whenever it detects a state change.
```swift
let statefulText = StatefulHostingView(state: 1) { state in // 1 is initial value
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

statefulText.state = 100 // When the state changes, SwiftUI re-renders the view.
```

> For more use cases, please refer to the [Demo](https://github.com/Jaesung-Jung/HostingView/tree/main/Demo) project.

## Requirements
- iOS 16+
- macCatalyst 16+
- tvOS 16+

## Install
### [Swift Package Manager](https://github.com/swiftlang/swift-package-manager)
The [Swift Package Manager](https://github.com/swiftlang/swift-package-manager) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.
```swift
import PackageDescription

let package = Package(
  name: "YourProject",
  dependencies: [
    .package(url: "https://github.com/Jaesung-Jung/HostingView.git", .upToNextMajor(from: "1.0"))
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

## License
MIT license. See [LICENSE](https://github.com/Jaesung-Jung/HostingView/blob/main/LICENSE) for details.
