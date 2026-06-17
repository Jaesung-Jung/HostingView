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
  private let switchControl = CustomSwitch()
  private let statusView = StatefulHostingView(state: Status(isOn: false, isEnabled: true, accentColor: .systemGreen)) { status in
    StatusCard(status: status)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Custom Control"
    view.backgroundColor = .systemGroupedBackground

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.spacing = 22
    view.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
      $0.centerY.equalToSuperview()
    }

    let titleView = HostingView {
      VStack(alignment: .leading, spacing: 8) {
        Text("UIKit owns the interaction")
          .font(.title2)
          .fontWeight(.black)

        Text("The custom control handles touch events in UIKit. SwiftUI renders the visual state through StatefulHostingView.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    stackView.addArrangedSubview(titleView)

    let controlContainer = UIView()
    controlContainer.backgroundColor = .secondarySystemGroupedBackground
    controlContainer.layer.cornerRadius = 24
    controlContainer.layer.cornerCurve = .continuous
    stackView.addArrangedSubview(controlContainer)

    controlContainer.addSubview(switchControl)
    switchControl.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.top.bottom.equalToSuperview().inset(28)
    }

    stackView.addArrangedSubview(statusView)

    let tintControl = UISegmentedControl(items: ["Green", "Blue", "Pink"])
    tintControl.selectedSegmentIndex = 0
    tintControl.addAction(UIAction { [weak self] _ in
      self?.updateTint(from: tintControl)
    }, for: .valueChanged)
    stackView.addArrangedSubview(tintControl)

    let buttonStackView = UIStackView()
    buttonStackView.axis = .horizontal
    buttonStackView.distribution = .fillEqually
    buttonStackView.spacing = 12
    stackView.addArrangedSubview(buttonStackView)

    let toggleButton = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Toggle") { [weak self] _ in
      self?.switchControl.isOn.toggle()
      self?.switchControl.sendActions(for: .valueChanged)
    })
    let enabledButton = UIButton(configuration: .bordered(), primaryAction: UIAction(title: "Disable") { [weak self] action in
      guard let self, let button = action.sender as? UIButton else {
        return
      }
      switchControl.isEnabled.toggle()
      button.configuration?.title = switchControl.isEnabled ? "Disable" : "Enable"
      updateStatus()
    })
    buttonStackView.addArrangedSubview(toggleButton)
    buttonStackView.addArrangedSubview(enabledButton)

    switchControl.addAction(UIAction { [weak self] _ in
      self?.updateStatus()
    }, for: .valueChanged)
    updateStatus()
  }

  private func updateTint(from control: UISegmentedControl) {
    switch control.selectedSegmentIndex {
    case 1:
      switchControl.onTintColor = .systemBlue
    case 2:
      switchControl.onTintColor = .systemPink
    default:
      switchControl.onTintColor = .systemGreen
    }
    updateStatus()
  }

  private func updateStatus() {
    statusView.state = Status(
      isOn: switchControl.isOn,
      isEnabled: switchControl.isEnabled,
      accentColor: switchControl.onTintColor
    )
  }
}

// MARK: - CustomControlViewController.Status

extension CustomControlViewController {
  struct Status: Equatable {
    var isOn: Bool
    var isEnabled: Bool
    var accentColor: UIColor
  }
}

// MARK: - CustomControlViewController.StatusCard

extension CustomControlViewController {
  struct StatusCard: View {
    let status: Status

    var body: some View {
      HStack(spacing: 14) {
        ZStack {
          Circle()
            .fill(Color(uiColor: status.accentColor).opacity(0.16))

          Image(systemName: status.isOn ? "bolt.fill" : "power")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(Color(uiColor: status.accentColor))
        }
        .frame(width: 48, height: 48)

        VStack(alignment: .leading, spacing: 4) {
          Text(status.isOn ? "Control is active" : "Control is inactive")
            .font(.headline)

          Text(status.isEnabled ? "UIKit events are enabled" : "UIKit events are disabled")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Text(status.isOn ? "ON" : "OFF")
          .font(.caption)
          .fontWeight(.black)
          .monospacedDigit()
          .foregroundStyle(Color(uiColor: status.accentColor))
          .padding(.vertical, 7)
          .padding(.horizontal, 10)
          .background(Color(uiColor: status.accentColor).opacity(0.12), in: Capsule())
      }
      .padding(16)
      .background(.background, in: RoundedRectangle(cornerRadius: 20))
      .overlay {
        RoundedRectangle(cornerRadius: 20)
          .stroke(.quaternary, lineWidth: 1)
      }
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

    var onTintColor: UIColor {
      get { contentView.state.onTintColor }
      set { contentView.state.onTintColor = newValue }
    }

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
        let activeColor = Color(uiColor: state.onTintColor)
        let inactiveColor = Color(uiColor: state.offTintColor)
        let backgroundColor = state.isEnabled
          ? (state.isOn ? activeColor : inactiveColor)
          : Color(uiColor: .systemGray5)
        let thumbColor = state.isEnabled ? Color.white : Color(uiColor: .systemGray3)

        ZStack {
          Capsule()
            .fill(backgroundColor)
            .overlay {
              Capsule()
                .stroke(.black.opacity(0.06), lineWidth: 1)
            }

          HStack {
            Text("OFF")
              .font(.caption2)
              .fontWeight(.black)
              .foregroundStyle(state.isEnabled ? (state.isOn ? .white.opacity(0.45) : .secondary) : .secondary.opacity(0.55))
              .frame(maxWidth: .infinity)

            Text("ON")
              .font(.caption2)
              .fontWeight(.black)
              .foregroundStyle(state.isEnabled ? (state.isOn ? .white : .secondary.opacity(0.55)) : .secondary.opacity(0.55))
              .frame(maxWidth: .infinity)
          }

          HStack {
            if state.isOn {
              Spacer(minLength: 0)
            }

            ZStack {
              Capsule()
                .fill(thumbColor)

              Image(systemName: state.isOn ? "checkmark" : "power")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(state.isEnabled ? (state.isOn ? activeColor : .secondary) : .secondary)
                .scaleEffect(state.isPressed ? 0.86 : 1)
            }
            .frame(width: state.isPressed ? 68 : 54, height: 54)
            .shadow(color: .black.opacity(state.isEnabled ? 0.18 : 0.06), radius: 7, x: 0, y: 4)

            if !state.isOn {
              Spacer(minLength: 0)
            }
          }
          .padding(5)
        }
        .frame(width: 148, height: 64)
        .saturation(state.isEnabled ? 1 : 0)
        .animation(.smooth(duration: 0.28), value: state.isOn)
        .animation(.smooth(duration: 0.18), value: state.isPressed)
        .animation(.smooth(duration: 0.2), value: state.isEnabled)
      }
      super.init(frame: frame)
      contentView.isUserInteractionEnabled = false
      addSubview(contentView)
      addAction(UIAction { [weak self] _ in
        guard let self, isEnabled else {
          return
        }
        contentView.state.isOn.toggle()
        sendActions(for: .valueChanged)
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
