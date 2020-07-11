//
//  Album.swift
//
//
//  Created by Shreyas Bangera on 08/04/2020.
//

import UIKit

public protocol ImageRepresentable {}
extension UIImage: ImageRepresentable {}
extension String: ImageRepresentable {}

public class AlbumViewModel: ViewModel {
    let images: [ImageRepresentable], currentIndex: Int
    public init(_ images: [ImageRepresentable], currentIndex: Int) {
        self.images = images
        self.currentIndex = currentIndex
        super.init()
    }
}

public class AlbumController: LightController<AlbumViewModel> {
    public override func render() {
        view.backgroundColor = .clear
        UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
            $0.layout = { $0.fillContainer() }
        }.add(to: view)
        CollectionView<String,ImageRepresentable>(.horizontal) {
            $0.isPagingEnabled = true
            $0.register(AlbumTableCell.self)
            $0.configureCell = { $0.dequeueCell(AlbumTableCell.self, $1) }
            $0.layout = { $0.fillContainer() }
        }.add(to: view).then { collection in
            collection.update(.empty, items: [viewModel.images])
            guard viewModel.currentIndex < viewModel.images.count else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [unowned self] in
                collection.scrollToItem(at: IndexPath(item: self.viewModel.currentIndex, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        UIButton(
            style: Styles.whiteBold15,
            title: "CLOSE",
            layout: { $0.top(20, context: .safe).right(20).dropShadow(opacity: 1, offset: .zero) },
            onTap: { [weak self] in self?.dismiss(animated: true, completion: nil) }
        ).add(to: view)
    }
}

final class AlbumTableCell: CollectionViewCell, Configurable {
    
    lazy var imgView = ImageView(mode: .scaleAspectFit, layout: { $0.fillContainer() }).then { imgView in
        imgView.isUserInteractionEnabled = true
        let reset = {
            UIView.animate(withDuration: 0.2, animations: {
                imgView.transform = CGAffineTransform.identity
            })
        }
        imgView.addGestureRecognizer(UITapGestureRecognizer().then {
            $0.numberOfTapsRequired = 2
            $0.onGesture {_ in reset() }
        })
        imgView.addGestureRecognizer(UIPinchGestureRecognizer { [weak self] in
            guard let view = $0.view, let cellWidth = self?.bounds.width else { return }
            switch $0.state {
            case .changed:
                let pinchCenter = CGPoint(x: $0.location(in: view).x - view.bounds.midX,
                                          y: $0.location(in: view).y - view.bounds.midY)
                view.transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                                                .scaledBy(x: $0.scale, y: $0.scale)
                                                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                $0.scale = 1
            case .ended:
                if view.frame.origin.x > 0 || view.frame.width + view.frame.origin.x < cellWidth {
                    reset()
                }
            default:
                return
            }
        })
    }
    
    override func render() {
        clipsToBounds = true
        imgView.add(to: self)
    }
    
    func configure(_ item: ImageRepresentable) {
        if let item = item as? String {
            imgView.load(item)
        } else if let item = item as? UIImage {
            imgView.image = item
        }
    }
}
