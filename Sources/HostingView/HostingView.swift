//
//  HostingView.swift
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

/// A UIKit view that hosts a hierarchy of SwiftUI views.
///
/// Use a hosting view when you want to place SwiftUI content directly in a
/// UIKit view hierarchy without managing a hosting controller. The view uses
/// Auto Layout sizing APIs to report the size of its SwiftUI content and
/// invalidates that size when the hosted content changes its geometry.
///
/// The following example creates a UIKit view that displays SwiftUI text:
///
/// ```swift
/// let titleView = HostingView {
///   Text("Hosting View")
///     .font(.largeTitle)
///     .fontWeight(.black)
/// }
/// ```
///
/// Add the resulting view to your UIKit hierarchy, and constrain it as you
/// would any other view:
///
/// ```swift
/// view.addSubview(titleView)
/// titleView.translatesAutoresizingMaskIntoConstraints = false
///
/// NSLayoutConstraint.activate([
///   titleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
///   titleView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
/// ])
/// ```
public class HostingView: UIView {
  private(set) var contentView: UIView!

  /// The natural size of the hosted SwiftUI content.
  ///
  /// The view measures its content using the current bounds width when one is
  /// available. This lets multiline and flexible SwiftUI content participate
  /// in Auto Layout using the width that the layout system has assigned.
  public override var intrinsicContentSize: CGSize {
    let targetWidth = bounds.width > .zero ? bounds.width : UIView.layoutFittingCompressedSize.width
    let horizontalPriority: UILayoutPriority = bounds.width > .zero ? .required : .fittingSizeLevel
    return contentView.systemLayoutSizeFitting(
      CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: horizontalPriority,
      verticalFittingPriority: .fittingSizeLevel
    )
  }

  /// The safe-area insets for the hosting view.
  ///
  /// This view reports zero safe-area insets so the hosted SwiftUI hierarchy
  /// can extend to the edges of the UIKit view that contains it.
  public override var safeAreaInsets: UIEdgeInsets {
    get { .zero }
    set {}
  }

  /// Creates a hosting view with the SwiftUI content that you provide.
  ///
  /// The initializer evaluates the view builder when creating the underlying
  /// hosting configuration. When SwiftUI reports a geometry change, the hosting
  /// view invalidates its intrinsic content size so Auto Layout can measure it
  /// again.
  ///
  /// - Parameter content: A view builder that creates the SwiftUI view
  ///   hierarchy to host.
  public init<Content: View>(@ViewBuilder content: () -> Content) {
    super.init(frame: .zero)
    let invalidateSize: @MainActor () -> Void = { [weak self] in
      self?.invalidateIntrinsicContentSize()
    }
    contentView = UIHostingConfiguration {
      content()
        .onGeometryChange(for: CGSize.self) {
          $0.size
        } action: { _ in
          invalidateSize()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: .all)
    }
    .margins(.all, 0)
    .makeContentView()

    addSubview(contentView)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
  }

  public override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
    systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .fittingSizeLevel,
      verticalFittingPriority: .fittingSizeLevel
    )
  }

  public override func systemLayoutSizeFitting(
    _ targetSize: CGSize,
    withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
    verticalFittingPriority: UILayoutPriority
  ) -> CGSize {
    contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
  }
}

// MARK: - HostingView Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  HostingView {
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
}
