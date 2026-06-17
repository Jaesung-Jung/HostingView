//
//  ProgressMeterViewController.swift
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

// MARK: - ProgressMeterViewController

final class ProgressMeterViewController: UIViewController {
  private let contentView = StatefulHostingView(state: State(progress: 0.42, title: "Preparing Upload")) { state in
    ProgressMeter(state: state)
  }

  private let slider = UISlider()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Progress Meter"
    view.backgroundColor = .systemBackground

    view.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(24)
      $0.centerY.equalToSuperview().offset(-44)
    }

    slider.minimumValue = 0
    slider.maximumValue = 1
    slider.value = Float(contentView.state.progress)
    slider.addAction(UIAction { [weak self] _ in
      self?.updateProgressFromSlider()
    }, for: .valueChanged)
    view.addSubview(slider)
    slider.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.top.equalTo(contentView.snp.bottom).offset(28)
    }

    let buttonStackView = UIStackView()
    buttonStackView.axis = .horizontal
    buttonStackView.distribution = .fillEqually
    buttonStackView.spacing = 12
    view.addSubview(buttonStackView)
    buttonStackView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
      $0.top.equalTo(slider.snp.bottom).offset(18)
    }

    let resetButton = UIButton(configuration: .bordered(), primaryAction: UIAction(title: "Reset") { [weak self] _ in
      self?.setProgress(0.12)
    })
    let completeButton = UIButton(configuration: .filled(), primaryAction: UIAction(title: "Complete") { [weak self] _ in
      self?.setProgress(1)
    })
    buttonStackView.addArrangedSubview(resetButton)
    buttonStackView.addArrangedSubview(completeButton)
  }

  private func updateProgressFromSlider() {
    setProgress(Double(slider.value))
  }

  private func setProgress(_ progress: Double) {
    let clampedProgress = min(max(progress, 0), 1)
    slider.setValue(Float(clampedProgress), animated: true)
    contentView.state = State(
      progress: clampedProgress,
      title: clampedProgress >= 1 ? "Upload Complete" : "Preparing Upload"
    )
  }
}

// MARK: - ProgressMeterViewController.State

extension ProgressMeterViewController {
  struct State: Equatable {
    var progress: Double
    var title: String
  }
}

// MARK: - ProgressMeterViewController.ProgressMeter

extension ProgressMeterViewController {
  struct ProgressMeter: View {
    let state: State

    var body: some View {
      VStack(spacing: 22) {
        ZStack {
          Circle()
            .stroke(.quaternary, lineWidth: 18)

          Circle()
            .trim(from: 0, to: state.progress)
            .stroke(
              .linearGradient(colors: [.cyan, .blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
              style: StrokeStyle(lineWidth: 18, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))

          VStack(spacing: 4) {
            Text(state.progress, format: .percent.precision(.fractionLength(0)))
              .font(.system(size: 44, weight: .black, design: .rounded))
              .monospacedDigit()

            Text(state.title)
              .font(.subheadline)
              .fontWeight(.medium)
              .foregroundStyle(.secondary)
          }
        }
        .frame(width: 220, height: 220)
        .animation(.smooth(duration: 0.25), value: state.progress)

        HStack(spacing: 8) {
          ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { milestone in
            Capsule()
              .fill(state.progress >= milestone ? Color.blue : Color(uiColor: .quaternaryLabel))
              .frame(height: 8)
          }
        }
      }
      .padding(24)
      .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 22))
    }
  }
}

// MARK: - ProgressMeterViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  ProgressMeterViewController()
}
