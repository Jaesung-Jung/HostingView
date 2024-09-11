//
//  MainViewController.swift
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

// MARK: - MainViewController

final class MainViewController: UIViewController, UICollectionViewDelegate {
  let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout.list(using: UICollectionLayoutListConfiguration(appearance: .insetGrouped))
  )

  lazy var dataSource = makeDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "HostingView Demo"
    navigationItem.backButtonDisplayMode = .minimal
    view.backgroundColor = .systemBackground

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    collectionView.delegate = self

    var snapshot = NSDiffableDataSourceSnapshot<Int, Menu>()
    snapshot.appendSections([0])
    snapshot.appendItems(Menu.allCases, toSection: 0)
    dataSource.apply(snapshot, animatingDifferences: false)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems else {
      return
    }
    transitionCoordinator?.animateAlongsideTransition(in: collectionView, animation: { [collectionView] _ in
      for indexPath in indexPathsForSelectedItems {
        collectionView.deselectItem(at: indexPath, animated: animated)
      }
    }, completion: { [collectionView] context in
      guard context.isCancelled else {
        return
      }
      for indexPath in indexPathsForSelectedItems {
        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: [])
      }
    })
  }

  func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, Menu> {
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Menu> { cell, indexPath, item in
      var configuration = UIListContentConfiguration.cell()
      configuration.text = item.title
      configuration.textProperties.font = .preferredFont(forTextStyle: .headline)
      configuration.secondaryText = item.category
      configuration.secondaryTextProperties.color = .secondaryLabel
      cell.contentConfiguration = configuration
      if #available(iOS 18.0, macCatalyst 18.0, tvOS 18.0, *) {
        cell.backgroundConfiguration = .listCell()
      } else {
        cell.backgroundConfiguration = .listGroupedCell()
      }
      cell.accessories = [.disclosureIndicator()]
    }
    return UICollectionViewDiffableDataSource<Int, Menu>(collectionView: collectionView) { collectionView, indexPath, item in
      return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let menu = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    switch menu {
    case .nameCard:
      navigationController?.pushViewController(NameCardViewController(), animated: true)
    case .gradientPage:
      navigationController?.pushViewController(GradientPageViewController(), animated: true)
    case .chart:
      navigationController?.pushViewController(ChartViewController(), animated: true)
    case .customControl:
      navigationController?.pushViewController(CustomControlViewController(), animated: true)
    }
  }
}

// MARK: - MainViewController.Menu

extension MainViewController {
  enum Menu: CaseIterable {
    case nameCard
    case gradientPage
    case chart
    case customControl

    var title: String {
      switch self {
      case .nameCard:
        return "Name Card"
      case .gradientPage:
        return "Gradient Page"
      case .chart:
        return "Chart"
      case .customControl:
        return "Custom Control"
      }
    }

    var category: String {
      switch self {
      case .nameCard, .gradientPage:
        return "HostingView"
      case .chart, .customControl:
        return "StatefulHostingView"
      }
    }
  }
}

// MARK: - MainViewController Preview

@available(iOS 17.0, macCatalyst 17.0, tvOS 17.0, *)
#Preview {
  UINavigationController(rootViewController: MainViewController())
}
