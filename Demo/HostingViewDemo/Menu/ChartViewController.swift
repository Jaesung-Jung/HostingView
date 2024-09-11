//
//  ChartViewController.swift
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
import Charts
import SnapKit
import HostingView

// MARK: - ChartViewController

final class ChartViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chart"
    view.backgroundColor = .systemBackground

    let randomData: () -> [Int] = { repeatElement((), count: 20).map { .random(in: 0...100) } }

    let chartView = LineChartView(data: randomData())
    view.addSubview(chartView)
    chartView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
      $0.centerY.equalToSuperview()
    }

    let reloadDataAction = UIAction(title: "Reload Data") { _ in
      chartView.data = randomData()
    }
    let reloadButton = UIButton(configuration: .filled(), primaryAction: reloadDataAction)
    view.addSubview(reloadButton)
    reloadButton.snp.makeConstraints {
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }
}

// MARK: - ChartViewController.LineChartView

extension ChartViewController {
  final class LineChartView: UIView {
    let contentView: StatefulHostingView<[Int]>

    var data: [Int] {
      get { contentView.state }
      set { contentView.state = newValue }
    }

    override var intrinsicContentSize: CGSize {
      CGSize(width: UIView.noIntrinsicMetric, height: contentView.intrinsicContentSize.height)
    }

    init(data: [Int]) {
      self.contentView = StatefulHostingView(state: data) { data in
        Chart {
          ForEach(data.indices, id: \.self) { index in
            LineMark(x: .value("x", index), y: .value("y", data[index]))
              .interpolationMethod(.catmullRom)
          }
        }
        .chartYScale(domain: 0...100)
        .animation(.snappy, value: data)
        .frame(height: 360)
      }
      super.init(frame: .zero)
      addSubview(contentView)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      contentView.frame = bounds
    }
  }
}

// MARK: - ChartViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  ChartViewController()
}
