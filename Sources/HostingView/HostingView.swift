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

import UIKit
import SwiftUI

// MARK: - HostingView

@MainActor
public class HostingView: UIView {
  private(set) var contentView: UIView!

  public override var intrinsicContentSize: CGSize {
    if frame.size == .zero {
      return contentView.intrinsicContentSize
    }
    return contentView.systemLayoutSizeFitting(frame.size, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
  }

  public init<Content: View>(@ViewBuilder content: () -> Content) {
    super.init(frame: .zero)
    let content = content()
    let invalidateSize: @MainActor () -> Void = { [weak self] in
      self?.invalidateIntrinsicContentSize()
    }
    contentView = UIHostingConfiguration {
      HostingLayout(invalidateSize) {
        content
      }
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      .ignoresSafeArea()
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
}

// MARK: - HostingView.HostingLayout

extension HostingView {
  struct HostingLayout: Layout {
    struct Cache {
      var sizes: [Int: CGSize] = [:]
    }

    let invalidateSize: @MainActor () -> Void

    init(_ invalidateSize: @MainActor @escaping () -> Void) {
      self.invalidateSize = invalidateSize
    }

    @inlinable func hash(_ proposedViewSize: ProposedViewSize) -> Int {
      var hasher = Hasher()
      hasher.combine(proposedViewSize.width)
      hasher.combine(proposedViewSize.height)
      return hasher.finalize()
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
      let key = hash(proposal)
      if let cachedSize = cache.sizes[key] {
        return cachedSize
      }
      let fittingSize = subviews.first?.sizeThatFits(proposal) ?? .zero
      cache.sizes[key] = fittingSize
      return fittingSize
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
      let position = CGPoint(x: max(0, bounds.origin.x), y: max(0, bounds.origin.y))
      for subview in subviews {
        subview.place(at: position, proposal: proposal)
      }
      Task {
        await MainActor.run {
          invalidateSize()
        }
      }
    }

    func makeCache(subviews: Subviews) -> Cache {
      Cache(
        sizes: [
          hash(.unspecified): subviews.first?.sizeThatFits(.unspecified) ?? .zero
        ]
      )
    }

    func updateCache(_ cache: inout Cache, subviews: Subviews) {
      cache.sizes.removeAll(keepingCapacity: true)
    }
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
