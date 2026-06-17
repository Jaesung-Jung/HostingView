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
    view.backgroundColor = .systemGroupedBackground

    let randomData: () -> [Int] = {
      var value = Int.random(in: 36...72)
      return repeatElement((), count: 24).map {
        value = min(max(value + Int.random(in: -14...16), 8), 96)
        return value
      }
    }

    let chartView = LineChartView(data: randomData())
    view.addSubview(chartView)
    chartView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.centerY.equalToSuperview().offset(-34)
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
        ChartCard(data: data)
      }
      super.init(frame: .zero)
      addSubview(contentView)
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

// MARK: - ChartViewController.ChartCard

extension ChartViewController {
  struct ChartCard: View {
    let data: [Int]

    private var average: Int {
      guard !data.isEmpty else {
        return 0
      }
      return data.reduce(0, +) / data.count
    }

    private var peak: Int {
      data.max() ?? 0
    }

    private var low: Int {
      data.min() ?? 0
    }

    private var trend: Int {
      guard let first = data.first, let last = data.last else {
        return 0
      }
      return last - first
    }

    var body: some View {
      VStack(alignment: .leading, spacing: 22) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 6) {
            Text("Traffic")
              .font(.caption)
              .fontWeight(.semibold)
              .foregroundStyle(.secondary)

            Text("Today")
              .font(.largeTitle)
              .fontWeight(.black)
          }

          Spacer()

          TrendBadge(value: trend)
        }

        HStack(spacing: 12) {
          MetricView(title: "Average", value: average, color: .blue)
          MetricView(title: "Peak", value: peak, color: .purple)
          MetricView(title: "Low", value: low, color: .teal)
        }

        Chart {
          ForEach(data.indices, id: \.self) { index in
            let value = data[index]

            AreaMark(
              x: .value("Hour", index),
              y: .value("Visitors", value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
              .linearGradient(
                colors: [.blue.opacity(0.32), .cyan.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
              )
            )

            LineMark(
              x: .value("Hour", index),
              y: .value("Visitors", value)
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .foregroundStyle(.linearGradient(colors: [.cyan, .blue, .indigo], startPoint: .leading, endPoint: .trailing))

          }

          RuleMark(y: .value("Average", average))
            .foregroundStyle(.secondary.opacity(0.35))
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 5]))
        }
        .chartYScale(domain: 0...100)
        .chartXAxis(.hidden)
        .chartYAxis {
          AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
            AxisGridLine()
              .foregroundStyle(.secondary.opacity(0.12))
            AxisValueLabel()
              .foregroundStyle(.secondary)
          }
        }
        .frame(height: 280)
        .animation(.snappy, value: data)
      }
      .padding(22)
      .background(.background, in: RoundedRectangle(cornerRadius: 24))
      .overlay {
        RoundedRectangle(cornerRadius: 24)
          .stroke(.quaternary, lineWidth: 1)
      }
      .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
  }
}

// MARK: - ChartViewController.MetricView

extension ChartViewController {
  struct MetricView: View {
    var title: String
    var value: Int
    var color: Color

    var body: some View {
      VStack(alignment: .leading, spacing: 6) {
        Text(title)
          .font(.caption2)
          .fontWeight(.semibold)
          .foregroundStyle(.secondary)

        Text("\(value)")
          .font(.title3)
          .fontWeight(.black)
          .monospacedDigit()
          .foregroundStyle(color)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 12)
      .padding(.horizontal, 14)
      .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
    }
  }
}

// MARK: - ChartViewController.TrendBadge

extension ChartViewController {
  struct TrendBadge: View {
    var value: Int

    private var isPositive: Bool {
      value >= 0
    }

    var body: some View {
      Label {
        Text("\(abs(value))")
          .monospacedDigit()
      } icon: {
        Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
      }
      .font(.caption)
      .fontWeight(.bold)
      .foregroundStyle(isPositive ? .green : .red)
      .padding(.vertical, 8)
      .padding(.horizontal, 10)
      .background((isPositive ? Color.green : Color.red).opacity(0.12), in: Capsule())
    }
  }
}

// MARK: - ChartViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  ChartViewController()
}
