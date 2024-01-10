//
//  W3WBottomSheetTableViewController.swift
//  
//
//  Created by Thy Nguyen on 20/12/2023.
//

import UIKit
import W3WSwiftCore
import W3WSwiftDesign

public class W3WBottomSheetTableViewController: W3WTableViewController<W3WSuggestion, W3WSuggestionsTableViewCell> {
  @available(iOS 13.0, *)
  typealias DataSource = UITableViewDiffableDataSource<W3WSearchResultSectionItem, W3WSearchResultCellItem>
  @available(iOS 13.0, *)
  typealias Snapshot = NSDiffableDataSourceSnapshot<W3WSearchResultSectionItem, W3WSearchResultCellItem>
  private var dataSource: AnyObject? = nil
  private var sections: [W3WSearchResultSectionItem] = []
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  public func setState(_ state: W3WOcrState) {
    let currentTitle = sections.first?.title
    let cellItem: W3WSearchResultCellItem = .state(item: W3WSingleLabelCellItem(ocrState: state, theme: theme, resultIsEmpty: getItems().isEmpty))
    let section: W3WSearchResultSectionItem = .init(type: .state, items: [cellItem])
    sections.removeAll(where: { $0.type == .state })
    sections.insert(section, at: 0)
    if sections.first?.title != currentTitle {
      if #available(iOS 13.0, *) {
        reloadDatasource()
      } else {
        tableView.beginUpdates()
        let stateSectionIdx = sections.firstIndex(where: { $0.type == .state }) ?? 0
        let rowToReload = IndexPath(row: 0, section: stateSectionIdx)
        tableView.reloadRows(at: [rowToReload], with: .fade)
        tableView.endUpdates()
      }
    }
  }
  
  public func insertMoreSuggestions(_ suggestions: [W3WSuggestion]) {
    let shouldReloadState = getItems().isEmpty
    let allSuggestions = suggestions + getItems()
    set(items: allSuggestions, reload: false)
    let cellItems: [W3WSearchResultCellItem] = allSuggestions.map {
      .result(item: W3WSuggestionCellItem(suggestion: $0))
    }
    let section: W3WSearchResultSectionItem = .init(type: .result, items: cellItems)
    sections.removeAll(where: { $0.type == .result })
    sections.append(section)
    if #available(iOS 13.0, *) {
      reloadDatasource()
    } else {
      tableView.beginUpdates()
      let resultSectionIdx = sections.firstIndex(where: { $0.type == .result }) ?? 0
      let rows = suggestions.enumerated().map { IndexPath(row: $0.offset, section: resultSectionIdx) }
      tableView.insertRows(at: rows, with: .top)
      tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
      tableView.endUpdates()
    }
    if shouldReloadState {
      setState(.scanned)
    }
  }
  
  private func setupUI() {
    tableView.separatorInsetReference = .fromAutomaticInsets
    tableView.register(W3WSingleLabelTableViewCell.self, forCellReuseIdentifier: W3WSingleLabelTableViewCell.cellIdentifier)
    if #available(iOS 13.0, *) {
      dataSource = makeDataSource()
      tableView.dataSource = dataSource as? DataSource
    }
    sections = [
      .init(type: .state, items: []),
      .init(type: .result, items: [])
    ]
  }
  
  @available(iOS 13.0, *)
  private func makeDataSource() -> DataSource? {
    let dataSource = DataSource(tableView: tableView) { (tableView, indexPath, cellItem) -> UITableViewCell? in
      switch cellItem {
      case .state(let item):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: W3WSingleLabelTableViewCell.cellIdentifier, for: indexPath) as? W3WSingleLabelTableViewCell else {
          fatalError("Can not dequeue cell")
        }
        cell.configure(with: item)
        cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
        return cell
      case .result(let item):
        guard let cell = tableView.dequeueReusableCell(withIdentifier: W3WSuggestionsTableViewCell.cellIdentifier, for: indexPath) as? W3WSuggestionsTableViewCell else {
          fatalError("Can not dequeue cell")
        }
        cell.configure(with: item)
        cell.set(scheme: .standard)
        cell.separatorInset = .init(top: 0, left: W3WMargin.heavy.value, bottom: 0, right: 0)
        return cell
      }
    }
    return dataSource
  }
  
  private func reloadDatasource() {
    guard #available(iOS 13.0, *) else {
      return
    }
    var snapshot = Snapshot()
    snapshot.appendSections(sections)
    sections.forEach { section in
      snapshot.appendItems(section.items, toSection: section)
    }
    (dataSource as? DataSource)?.apply(snapshot, animatingDifferences: true)
  }
  
  // MARK: - UITableViewDelegate
  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let sectionItem = sections[indexPath.section]
    let cellItem = sectionItem.items[indexPath.row]
    switch cellItem {
    case .state:
      return UITableView.automaticDimension
    case .result:
      return rowHeight
    }
  }
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let sectionItem = sections[indexPath.section]
    let cellItem = sectionItem.items[indexPath.row]
    if case .result = cellItem  {
      super.tableView(tableView, didSelectRowAt: indexPath)
    }
  }
  
  // MARK: - UITableViewDataSource
  public override func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].items.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let sectionItem = sections[indexPath.section]
    let cellItem = sectionItem.items[indexPath.row]
    switch cellItem {
    case .state(let item):
      guard let cell = tableView.dequeueReusableCell(withIdentifier: W3WSingleLabelTableViewCell.cellIdentifier, for: indexPath) as? W3WSingleLabelTableViewCell else {
        fatalError("Can not dequeue cell")
      }
      cell.configure(with: item)
      cell.separatorInset = UIEdgeInsets(top: 0, left: .greatestFiniteMagnitude, bottom: 0, right: 0)
      return cell
    case .result(let item):
      guard let cell = tableView.dequeueReusableCell(withIdentifier: W3WSuggestionsTableViewCell.cellIdentifier, for: indexPath) as? W3WSuggestionsTableViewCell else {
        fatalError("Can not dequeue cell")
      }
      cell.configure(with: item)
      cell.set(scheme: .standard)
      cell.separatorInset = .init(top: 0, left: W3WMargin.heavy.value, bottom: 0, right: 0)
      return cell
    }
  }
}
