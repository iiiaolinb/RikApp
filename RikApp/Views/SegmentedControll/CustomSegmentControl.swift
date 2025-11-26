//
//  CustomSegmentControl.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//


import UIKit
import PinLayout

// MARK: - CustomSegmentedControlDelegate
protocol CustomSegmentedControlDelegate: AnyObject {
    func segmentedControl(_ control: CustomSegmentedControl, didSelectItemAt index: Int)
}

// MARK: - CustomSegmentedControl
final class CustomSegmentedControl: UIView {

    private var items: [String]
    private var collectionView: UICollectionView!
    private var selectedIndex: Int = 0
    weak var delegate: CustomSegmentedControlDelegate?

    private let cellPadding: CGFloat = 16
    private var cellWidths: [CGFloat] = []

    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setupCollectionView()
        calculateCellWidths()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SegmentCell.self, forCellWithReuseIdentifier: "SegmentCell")

        addSubview(collectionView)
    }

    private func calculateCellWidths() {
        cellWidths = items.map { title in
            let font = Constants.AppFont.medium(size: 14).font
            let width = (title as NSString).size(withAttributes: [.font: font]).width + cellPadding * 2
            return width
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.pin.all()
    }

    func selectItem(at index: Int, animated: Bool = true) {
        guard index >= 0, index < items.count else { return }
        let oldIndex = selectedIndex
        selectedIndex = index
        
        let indexPathsToReload: [IndexPath] = [IndexPath(item: oldIndex, section: 0),
                                              IndexPath(item: selectedIndex, section: 0)]
        collectionView.reloadItems(at: indexPathsToReload)
        scrollToCenter(index: index, animated: animated)
        delegate?.segmentedControl(self, didSelectItemAt: index)
    }

    private func scrollToCenter(index: Int, animated: Bool) {
        let offsetX = cellWidths.prefix(index).reduce(0, +) + cellWidths[index] / 2 - collectionView.bounds.width / 2
        let maxOffsetX = collectionView.contentSize.width - collectionView.bounds.width
        let finalOffset = max(0, min(offsetX, maxOffsetX))
        collectionView.setContentOffset(CGPoint(x: finalOffset, y: 0), animated: animated)
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension CustomSegmentedControl: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
        cell.configure(title: items[indexPath.item], isSelected: indexPath.item == selectedIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItem(at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidths[indexPath.item], height: collectionView.bounds.height)
    }
}


