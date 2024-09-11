//
//  NameCardViewController.swift
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

// MARK: - NameCardViewController

final class NameCardViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Name Card"
    view.backgroundColor = .systemBackground

    let imageURL = URL(string: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500")

    let cardView = HostingView {
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .fill(.white)
          .shadow(radius: 8, x: 0, y: 4)

        VStack(spacing: 0) {
          Spacer()

          AsyncImage(url: imageURL) {
            $0.resizable().aspectRatio(contentMode: .fill)
          } placeholder: {
            Color.gray.opacity(0.25)
          }
          .frame(width: 100, height: 100)
          .mask {
            Circle()
          }
          .overlay {
            Circle()
              .stroke(.gray.opacity(0.25), lineWidth: 1)
          }

          Spacer()

          VStack(spacing: 16) {
            VStack(spacing: 4) {
              Text("John Doe")
                .fontWeight(.bold)

              Text("Software Engineer")
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            VStack(spacing: 4) {
              Text(verbatim: "123-456-7890")
              Text(verbatim: "john.doe@email.com")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            Divider()

            Text(verbatim: "COMPANY Inc.")
              .font(.caption)
              .fontWeight(.black)

            Spacer()
              .frame(height: 0)
          }
        }
      }
      .frame(width: 220, height: 320)
    }
    view.addSubview(cardView)
    cardView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}

// MARK: - NameCardViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  NameCardViewController()
}
