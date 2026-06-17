//
//  NotificationCardViewController.swift
//
//  Copyright © 2026 Jaesung Jung. All rights reserved.
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

// MARK: - NotificationCardViewController

final class NotificationCardViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Notification Card"
    view.backgroundColor = .systemGroupedBackground

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 16
    view.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.centerY.equalToSuperview()
    }

    let messages = [
      Message(sender: "Design", title: "Prototype review", body: "The SwiftUI card is hosted inside UIKit and measured by Auto Layout.", accentColor: .purple, symbolName: "sparkles"),
      Message(sender: "Build", title: "Ready to ship", body: "This example has no SwiftUI interaction. UIKit owns placement and layout.", accentColor: .teal, symbolName: "checkmark.seal.fill"),
      Message(sender: "Support", title: "Follow-up needed", body: "Longer text wraps naturally while the hosting view reports its intrinsic height.", accentColor: .orange, symbolName: "bubble.left.and.bubble.right.fill")
    ]

    for message in messages {
      let cardView = HostingView {
        NotificationCard(message: message)
      }
      stackView.addArrangedSubview(cardView)
    }
  }
}

// MARK: - NotificationCardViewController.Message

extension NotificationCardViewController {
  struct Message {
    var sender: String
    var title: String
    var body: String
    var accentColor: Color
    var symbolName: String
  }
}

// MARK: - NotificationCardViewController.NotificationCard

extension NotificationCardViewController {
  struct NotificationCard: View {
    let message: Message

    var body: some View {
      HStack(alignment: .top, spacing: 14) {
        ZStack {
          Circle()
            .fill(message.accentColor.opacity(0.16))

          Image(systemName: message.symbolName)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(message.accentColor)
        }
        .frame(width: 44, height: 44)

        VStack(alignment: .leading, spacing: 8) {
          HStack(alignment: .firstTextBaseline) {
            Text(message.sender)
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundStyle(message.accentColor)

            Spacer(minLength: 12)

            Text("Now")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }

          Text(message.title)
            .font(.headline)
            .foregroundStyle(.primary)

          Text(message.body)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(16)
      .background(.background, in: RoundedRectangle(cornerRadius: 14))
      .overlay {
        RoundedRectangle(cornerRadius: 14)
          .stroke(.quaternary, lineWidth: 1)
      }
    }
  }
}

// MARK: - NotificationCardViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  NotificationCardViewController()
}
