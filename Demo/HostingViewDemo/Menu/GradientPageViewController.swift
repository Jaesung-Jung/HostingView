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
    view.backgroundColor = .systemGroupedBackground

    let showcaseView = HostingView {
      GradientShowcase()
    }
    view.addSubview(showcaseView)
    showcaseView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.centerY.equalToSuperview()
    }
  }
}

// MARK: - GradientPageViewController.GradientShowcase

extension GradientPageViewController {
  struct GradientShowcase: View {
    var body: some View {
      VStack(alignment: .leading, spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
          Text("Gradient Gallery")
            .font(.largeTitle)
            .fontWeight(.black)

          Text("A noninteractive SwiftUI composition hosted inside UIKit.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        VStack(spacing: 14) {
          HStack(spacing: 14) {
            GradientTile(title: "Linear", subtitle: "Top leading to bottom trailing") {
              RoundedRectangle(cornerRadius: 24)
                .fill(.linearGradient(colors: [.indigo, .cyan, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
            }

            GradientTile(title: "Radial", subtitle: "Soft center glow") {
              RoundedRectangle(cornerRadius: 24)
                .fill(.radialGradient(colors: [.yellow, .orange, .pink], center: .center, startRadius: 12, endRadius: 140))
            }
          }

          HStack(spacing: 14) {
            GradientTile(title: "Angular", subtitle: "Color wheel sweep") {
              RoundedRectangle(cornerRadius: 24)
                .fill(.angularGradient(colors: [.pink, .orange, .blue, .purple, .pink], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)))
            }

            GradientTile(title: "Elliptical", subtitle: "Wide ambient wash") {
              RoundedRectangle(cornerRadius: 24)
                .fill(.ellipticalGradient(colors: [.teal, .cyan, .indigo]))
            }
          }

          GradientTile(title: "Mesh", subtitle: "iOS 18 color field") {
            MeshGradientView()
          }
        }

        HostingNote()
      }
    }
  }
}

// MARK: - GradientPageViewController.MeshGradientView

extension GradientPageViewController {
  struct MeshGradientView: View {
    var body: some View {
      if #available(iOS 18.0, macCatalyst 18.0, tvOS 18.0, *) {
        RoundedRectangle(cornerRadius: 24)
          .fill(
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
      } else {
        RoundedRectangle(cornerRadius: 24)
          .fill(.linearGradient(colors: [.red, .purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
          .overlay {
            Circle()
              .fill(.white.opacity(0.26))
              .blur(radius: 20)
              .padding(34)
          }
      }
    }
  }
}

// MARK: - GradientPageViewController.GradientTile

extension GradientPageViewController {
  struct GradientTile<Content: View>: View {
    var title: String
    var subtitle: String
    @ViewBuilder var content: () -> Content

    var body: some View {
      ZStack(alignment: .bottomLeading) {
        content()
          .frame(height: 150)
          .overlay {
            RoundedRectangle(cornerRadius: 24)
              .stroke(.white.opacity(0.35), lineWidth: 1)
          }

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .font(.headline)
            .fontWeight(.black)
            .foregroundStyle(.white)

          Text(subtitle)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white.opacity(0.78))
            .lineLimit(2)
            .minimumScaleFactor(0.8)
        }
        .padding(14)
      }
      .frame(maxWidth: .infinity)
      .background(.background, in: RoundedRectangle(cornerRadius: 24))
      .clipShape(RoundedRectangle(cornerRadius: 24))
      .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
  }
}

// MARK: - GradientPageViewController.HostingNote

extension GradientPageViewController {
  struct HostingNote: View {
    var body: some View {
      HStack(spacing: 12) {
        Image(systemName: "viewfinder")
          .font(.system(size: 18, weight: .bold))
          .foregroundStyle(.blue)

        Text("HostingView measures this SwiftUI gallery as one UIKit view.")
          .font(.footnote)
          .fontWeight(.medium)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding(16)
      .background(.background, in: RoundedRectangle(cornerRadius: 18))
      .overlay {
        RoundedRectangle(cornerRadius: 18)
          .stroke(.quaternary, lineWidth: 1)
      }
    }
  }
}

// MARK: - GradientPageViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  GradientPageViewController()
}
