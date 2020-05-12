//
//  TableView.swift
//  Plowz & Mowz
//
//  Created by SpringRole on 24/10/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
//

import UIKit

public protocol Expandable {
    var isExpanded: Bool { get }
}

public extension Expandable {
    var isExpanded: Bool { true }
}

extension String: Expandable {}

public class TableView<Section: Expandable,Item>: UITableView, UITableViewDataSource, UITableViewDelegate {
    private let disposable = Disposable()
    private var data = [List<Section,Item>]()
    var original = [List<Section,Item>]()
    var isExpanded = [Bool?]()
    public var didSelect: ((TableView<Section,Item>, ListItem<Item>) -> Void)?
    public var didDeSelect: ((TableView<Section,Item>, ListItem<Item>) -> Void)?
    public var header: ((TableView<Section,Item>, Int, Section) -> UIView?)?
    public var footer: ((TableView<Section,Item>, Int, Section) -> UIView?)?
    public var headerHeight: ((Int) -> CGFloat)?
    public var footerHeight: ((Int) -> CGFloat)?
    public var configureCell: ((TableView<Section,Item>, ListItem<Item>) -> UITableViewCell)?
    public var canEdit: ((TableView<Section,Item>, ListItem<Item>) -> Bool)?
    var dynamicData: Dynamic<[Item]>?
    public var onDelete: FinallyBlock = nil

    public init(_ data: Dynamic<[Item]>? = nil, closure: (TableView<Section,Item>) -> Void) {
        super.init(frame: .zero, style: .plain)
        separatorStyle = .none
        backgroundColor = .clear
        tableFooterView = UIView()
        dataSource = self
        delegate = self
        estimatedRowHeight = 0
        estimatedSectionHeaderHeight = 0
        estimatedSectionFooterHeight = 0
        rowHeight = UITableView.automaticDimension
        showsVerticalScrollIndicator = false
        closure(self)
        bind(to: data)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].items?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = data[indexPath.section].items?[indexPath.row],
            let cell = configureCell?(self, .init(index: indexPath, item: item)) else {
                return UITableViewCell()
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didSelect?(self, .init(index: indexPath, item: item))
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didDeSelect?(self, .init(index: indexPath, item: item))
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //https://stackoverflow.com/questions/28244475/reloaddata-of-uitableview-with-dynamic-cell-heights-causes-jumpy-scrolling
    var cellHeights = [IndexPath: CGFloat]()

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let item = data[section].section else { return nil }
        return header?(self, section, item)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let item = data[section].section else { return nil }
        return footer?(self, section, item)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return data[section].section.isNil ? 0 : headerHeight?(section) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return data[section].section.isNil ? 0 : footerHeight?(section) ?? UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return false }
        return canEdit?(self, .init(index: indexPath, item: item)) ?? false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dynamicData?.remove(at: indexPath.row)
            onDelete?()
        }
    }
    
    public func update(_ sections: [Section?] = .empty, items: [[Item]?] = .empty) {
        let list = List.dataSource(sections: sections, items: items)
        isExpanded = sections.map { $0?.isExpanded }
        if isExpanded.isEmpty { isExpanded = [true] }
        original = list
        data = List.dataSource(sections: sections, items: isExpanded.enumerated().map { $1 == true ? items[$0] : .empty })
        reloadData()
    }
    
    public func toggle(_ section: Int) {
        isExpanded[section]?.toggle()
        data[section].items = true == isExpanded[section] ? original[section].items : .empty
        reloadSectionWithoutAnimation(section: section)
    }
    
    func reloadSectionWithoutAnimation(section: Int) {
        UIView.performWithoutAnimation {
            let offset = self.contentOffset
            self.reloadSections(IndexSet(integer: section), with: .none)
            self.contentOffset = offset
        }
    }
    
    public func isSectionExpanded(_ section: Int) -> Bool {
        isExpanded[section].value
    }
    
    public func bind(to data: Dynamic<[Item]>?) {
        dynamicData = data
        data?.updateAndSubscribe({ [weak self] in
            self?.update(.empty, items: [$0])
        }, disposeWith: disposable)
        data?.onRemove = { [weak self] in
            self?.remove($0)
        }
    }
    
    public func remove(_ index: Int) {
        data[0].items?.remove(at: index)
        deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    deinit {
        disposable.dispose()
    }
}

open class TableViewCell: UITableViewCell {
    
    public let disposable = Disposable()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        render()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    open func render() {}
    
    deinit {
        disposable.dispose()
    }
}

open class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    public let disposable = Disposable()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        render()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }
    
    open func render() {}
    
    deinit {
        disposable.dispose()
    }
}

public extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseId)
    }
    
    func register<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseId)
    }
    
    func dequeueCell<T: UITableViewCell>(_: T.Type, at index: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.reuseId, for: index) as! T
    }
    
    func dequeueCell<T: UITableViewCell & Configurable, U>(_: T.Type,_ item: ListItem<U>) -> T where T.T == U {
        dequeueCell(T.self, at: item.index).then { $0.configureView(item.item) }
    }
    
    func dequeueHeader<T: UITableViewHeaderFooterView>(_: T.Type) -> T {
        dequeueReusableHeaderFooterView(withIdentifier: T.reuseId) as! T
    }
    
    func dequeueHeader<T: UITableViewHeaderFooterView & Configurable, U>(_: T.Type,_ item: U) -> T where T.T == U {
        dequeueHeader(T.self).then { $0.configureView(item) }
    }
    
    @discardableResult
    func cell<T: UITableViewCell>(_: T.Type, at index: IndexPath) -> T {
        cellForRow(at: index) as! T
    }
}
