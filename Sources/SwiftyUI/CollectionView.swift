//
//  CollectionView.swift
//  Plowz & Mowz
//
//  Created by SpringRole on 24/10/2019.
//  Copyright © 2019 SpringRole. All rights reserved.
//

import UIKit

public class CollectionView<Section,Item>: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let disposable = Disposable()
    private var data = [List<Section,Item>]()
    var lineSpacing: CGFloat = 0
    var itemSpacing: CGFloat = 0
    var width: CGFloat?
    var height: CGFloat?
    let widthFactor: CGFloat
    let heightFactor: CGFloat
    let widthOffset: CGFloat
    let heightOffset: CGFloat
    var isSquare: Bool
    var hideIfEmpty: Bool
    var visibilityChanged, visibilityShouldChange: FinallyBlock
    public var didSelect: ((CollectionView<Section,Item>, ListItem<Item>) -> Void)?
    public var didDeSelect: ((CollectionView<Section,Item>, ListItem<Item>) -> Void)?
    public var configureCell: ((CollectionView<Section,Item>, ListItem<Item>) -> UICollectionViewCell)?
    public var didScrollToIndex: ((IndexPath) -> Void)?
    public var didScrollToOffset: ((CGFloat) -> Void)?
    public var didScroll: ((UIScrollView) -> Void)?
    public var supplementaryViewHeight: ((CollectionView<Section,Item>, Int) -> CGSize)?
    public var supplementaryView: ((CollectionView<Section,Item>, CollectionSupplementaryItem<Section>) -> UICollectionReusableView)?
    
    public init(_ scrollDirection: UICollectionView.ScrollDirection,
         data: Dynamic<[Item]>? = nil,
         lineSpacing: CGFloat = 0,
         itemSpacing: CGFloat = 0,
         widthFactor: CGFloat = 1,
         heightFactor: CGFloat = 1,
         widthOffset: CGFloat = 0,
         heightOffset: CGFloat = 0,
         width: CGFloat? = nil,
         height: CGFloat? = nil,
         isSquare: Bool = false,
         isDynamic: Bool = false,
         hideIfEmpty: Bool = false,
         visibilityChanged: FinallyBlock = nil,
         visibilityShouldChange: FinallyBlock = nil,
         closure: (CollectionView<Section,Item>) -> Void) {
        let layout = UICollectionViewFlowLayout()
        if isDynamic {
            if #available(iOS 10.0, *) {
                layout.itemSize = UICollectionViewFlowLayout.automaticSize
            }
        }
        layout.scrollDirection = scrollDirection
        self.widthFactor = widthFactor
        self.heightFactor = heightFactor
        self.widthOffset = widthOffset
        self.heightOffset = heightOffset
        self.isSquare = isSquare
        self.hideIfEmpty = hideIfEmpty
        self.visibilityChanged = visibilityChanged
        self.visibilityShouldChange = visibilityShouldChange
        super.init(frame: .zero, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        self.lineSpacing = lineSpacing
        self.itemSpacing = itemSpacing
        self.width = width
        self.height = height
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        closure(self)
        bind(to: data)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].items?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = data[indexPath.section].items?[indexPath.row],
            let cell = configureCell?(self, .init(index: indexPath, item: item)) else {
                return UICollectionViewCell()
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = width ?? widthFactor * collectionView.bounds.size.width + widthOffset
        let cellHeight = isSquare ? cellWidth : (height ?? heightFactor * collectionView.bounds.size.height) + heightOffset
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didSelect?(self, .init(index: indexPath, item: item))
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = data[indexPath.section].items?[indexPath.row] else { return }
        didDeSelect?(self, .init(index: indexPath, item: item))
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        supplementaryViewHeight?(self, section) ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let item = data[indexPath.section].section else { return UICollectionReusableView() }
        return supplementaryView?(self, CollectionSupplementaryItem(kind: kind, index: indexPath, item: item)) ?? UICollectionReusableView()
    }
    
    public func update(_ sections: [Section?] = .empty, items: [[Item]?] = .empty) {
        data = List.dataSource(sections: sections, items: items)
        reloadData()
    }
    
    public func bind(to data: Dynamic<[Item]>?) {
        guard let data = data else { return }
        data.updateAndSubscribe({ [weak self] in
            if self?.hideIfEmpty == true {
                if self?.data.first?.items?.isEmpty != $0.isEmpty {
                    self?.hideFromStack($0.isEmpty)
                    self?.visibilityChanged?()
                }
            } else {
                if self?.data.first?.items?.isEmpty != $0.isEmpty {
                    self?.visibilityShouldChange?()
                }
            }
            self?.update(.empty, items: [$0])
        }, disposeWith: disposable)
        data.onRemove = { [weak self] in
            self?.remove($0)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didScrollToOffset?(contentOffset.x)
        if scrollView.tag == 0 {
            let center = CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width/2, y: scrollView.frame.height/2)
            if let index = self.indexPathForItem(at: center) {
                didScrollToIndex?(index)
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        didScroll?(scrollView)
    }
    
    func remove(_ index: Int) {
        performBatchUpdates({
            data[0].items?.remove(at: index)
            deleteItems(at: [IndexPath(item: index, section: 0)])
        }, completion: nil)
    }
    
    deinit {
        disposable.dispose()
    }
}

open class CollectionViewCell: UICollectionViewCell {
    
    public let disposable = Disposable()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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

open class CollectionReusableView: UICollectionReusableView {
    
    public let disposable = Disposable()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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

public extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseId)
    }
    
    func registerHeader<T: UICollectionReusableView>(_: T.Type) {
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.reuseId)
    }
    
    func registerFooter<T: UICollectionReusableView>(_: T.Type) {
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.reuseId)
    }
    
    func dequeueCell<T: UICollectionViewCell>(_: T.Type, at index: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.reuseId, for: index) as! T
    }
    
    func dequeueCell<T: UICollectionViewCell & Configurable, U>(_: T.Type, _ item: ListItem<U>) -> T where T.T == U {
        dequeueCell(T.self, at: item.index).then { $0.configureView(item.item) }
    }
    
    func dequeueReusableView<T: UICollectionReusableView>(_: T.Type, of kind: String, at index: IndexPath) -> T {
        dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseId, for: index) as! T
    }
    
    func dequeueReusableView<T: UICollectionReusableView & Configurable, U>(_: T.Type,_ item: CollectionSupplementaryItem<U>) -> T where T.T == U {
        (dequeueReusableSupplementaryView(ofKind: item.kind, withReuseIdentifier: T.reuseId, for: item.index) as! T).then { $0.configureView(item.item) }
    }
    
    @discardableResult
    func cell<T: UICollectionViewCell>(_: T.Type, at index: IndexPath) -> T {
        cellForItem(at: index) as! T
    }
}

public struct ListItem<T> {
    public let index: IndexPath
    public let item: T
    public init(index: IndexPath, item: T) {
        self.index = index
        self.item = item
    }
}

public struct CollectionSupplementaryItem<T> {
    public let kind: String
    public let index: IndexPath
    public let item: T
}
