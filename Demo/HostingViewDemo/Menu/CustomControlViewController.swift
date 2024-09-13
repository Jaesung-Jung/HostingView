//
//  CustomControlViewController.swift
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

// MARK: - CustomControlViewController

final class CustomControlViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Custom Control"
    view.backgroundColor = .systemBackground

    let switchControl = CustomSwitch()
    view.addSubview(switchControl)
    switchControl.snp.makeConstraints {
      $0.center.equalToSuperview()
    }

    let switchStateLabel = UILabel()
    switchStateLabel.text = switchControl.isOn ? "ON" : "OFF"
    switchControl.addAction(UIAction { [switchStateLabel] action in
      guard let switchControl = action.sender as? CustomSwitch else {
        return
      }
      switchStateLabel.text = switchControl.isOn ? "ON" : "OFF"
    }, for: .valueChanged)
    view.addSubview(switchStateLabel)
    switchStateLabel.snp.makeConstraints {
      $0.top.equalTo(switchControl.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
    }
  }
}

// MARK: - CustomControlViewController.CustomSwitch

extension CustomControlViewController {
  final class CustomSwitch: UIControl {
    struct State {
      var isOn: Bool = false
      var isPressed: Bool = false
      var isEnabled: Bool = true

      var onTintColor: UIColor = .systemGreen
      var offTintColor: UIColor = .systemGray5
    }

    let contentView: StatefulHostingView<State>

    override var intrinsicContentSize: CGSize { contentView.intrinsicContentSize }

    @inlinable var isOn: Bool {
      get { contentView.state.isOn }
      set { contentView.state.isOn = newValue }
    }

    override var isHighlighted: Bool {
      didSet {
        contentView.state.isPressed = isHighlighted
      }
    }

    override var isEnabled: Bool {
      didSet {
        contentView.state.isEnabled = isEnabled
      }
    }

    override init(frame: CGRect) {
      self.contentView = StatefulHostingView(state: State()) { state in
        HStack {
          if state.isOn {
            Spacer()
          }
          Capsule(style: .circular)
            .fill(.white)
            .padding(2)
            .aspectRatio(state.isPressed ? 1.25 : 1, contentMode: .fit)
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
            .overlay {
              ZStack {
                Image(systemName: "circle")
                  .scaleEffect(x: state.isOn ? 0 : 1, y: state.isOn ? 0 : 1, anchor: .center)
                Image(systemName: "checkmark")
                  .scaleEffect(x: state.isOn ? 1 : 0, y: state.isOn ? 1 : 0, anchor: .center)
              }
              .imageScale(.small)
            }
          if !state.isOn {
            Spacer()
          }
        }
        .background(state.isOn ? Color(uiColor: state.onTintColor) : Color(uiColor: state.offTintColor))
        .mask {
          Capsule()
        }
        .animation(.smooth(duration: 0.3), value: state.isOn)
        .animation(.smooth(duration: 0.3), value: state.isPressed)
        .opacity(state.isEnabled ? 1 : 0.5)
        .frame(width: 51, height: 31)
      }
      super.init(frame: frame)
      contentView.isUserInteractionEnabled = false
      addSubview(contentView)
      addAction(UIAction { [weak self] _ in
        self?.contentView.state.isOn.toggle()
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
}

// MARK: - CustomControlViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  CustomControlViewController()
}
