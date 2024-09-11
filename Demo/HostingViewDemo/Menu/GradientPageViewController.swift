//
//  GradientPageViewController.swift
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
import SnapKit
import HostingView

// MARK: - GradientPageViewController

final class GradientPageViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Gradient Page"
    view.backgroundColor = .systemBackground

    let pageView = HostingView {
      TabView {
        VStack {
          Text("Linear Gradient")
          ShapeView(.linearGradient(colors: [.indigo, .cyan, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
          Spacer()
        }

        VStack {
          Text("Elliptical Gradient")
          ShapeView(.ellipticalGradient(colors: [.teal, .cyan, .indigo]))
          Spacer()
        }

        VStack {
          Text("Angular Gradient")
          ShapeView(.angularGradient(colors: [.pink, .orange, .blue, .pink], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)))
          Spacer()
        }

        if #available(iOS 18.0, macCatalyst 18.0, tvOS 18.0, *) {
          VStack {
            Text("Mesh Gradient")
            ShapeView(
              MeshGradient(
                width: 3,
                height: 3,
                points: [
                  .init(0, 0), .init(0.5, 0), .init(1, 0),
                  .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                  .init(0, 1), .init(0.5, 1), .init(1, 1)
                ],
                colors: [
                  .red, .purple, .indigo,
                  .orange, .white, .blue,
                  .yellow, .green, .mint
                ]
              )
            )
            Spacer()
          }
        }
      }
      .fontWeight(.bold)
      .tabViewStyle(.page)
    }
    view.addSubview(pageView)
    pageView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }

    let textLabel = UILabel()
    textLabel.text = "You can swipe left and right."
    textLabel.textAlignment = .center
    textLabel.font = .preferredFont(forTextStyle: .headline)
    view.addSubview(textLabel)
    textLabel.snp.makeConstraints {
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
    }
  }
}

// MARK: - GradientPageViewController.ShapeView

extension GradientPageViewController {
  struct ShapeView<Shape: ShapeStyle>: View {
    let shape: Shape

    init(_ shape: Shape) {
      self.shape = shape
    }

    var body: some View {
      RoundedRectangle(cornerRadius: 20)
        .fill(shape)
        .aspectRatio(1, contentMode: .fit)
        .padding(20)
    }
  }
}

// MARK: - GradientPageViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  GradientPageViewController()
}
