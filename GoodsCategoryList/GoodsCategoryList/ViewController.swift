//
//  ViewController.swift
//  GoodsCategoryList
//
//  Created by 提运佳 on 2018/7/12.
//  Copyright © 2018年 提运佳. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftView: UITableView!
    @IBOutlet weak var rightView: UICollectionView!
    @IBOutlet weak var contentViewTop: NSLayoutConstraint!
    
    private let categoryNum = 30
    private let goodsNum = 20
    private var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "商品分类"
        setupTableView()
        setupCollectionView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == leftView {
            self.contentViewAnimation(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if scrollView == rightView {
                print("1 === scrollViewDidEndDragging")
                offsetForRight(scrollView: scrollView)
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == rightView {
            print("2 === scrollViewDidEndDecelerating")
            offsetForRight(scrollView: scrollView)
        }
    }
    
    private func contentViewAnimation(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            UIView.animate(withDuration: 0.2) {
                self.contentViewTop.constant = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.contentViewTop.constant = 80
            }
        }
    }
    
    private func offsetForRight(scrollView: UIScrollView) {
        let scrollHeight = scrollView.frame.size.height
        let contentOffsetY = scrollView.contentOffset.y
        let bottomOffset = scrollView.contentSize.height - contentOffsetY
        
        if bottomOffset <= scrollHeight {
            let bottomIndexPath = rightView.indexPathsForVisibleItems.last
            self.selectedCellFor(leftView: leftView, row: (bottomIndexPath?.section)!)
        } else {
            let topIndexPath = rightView.indexPathsForVisibleItems.first
            self.selectedCellFor(leftView: leftView, row: (topIndexPath?.section)!)
        }
    }
    
    private func selectedCellFor(leftView: UITableView, row: Int) {
        let selectIndexPath = IndexPath(row: row, section: 0)
        selectedIndexPath = selectIndexPath
        leftView.reloadData()
        
        leftView.selectRow(at: selectIndexPath, animated: true, scrollPosition: .middle)
    }
    
}

//MARK: - leftView
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftCell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.text = "分类\(indexPath.row+1)"
        if indexPath == selectedIndexPath {
            cell.backgroundColor = UIColor.green
            cell.textLabel?.textColor = UIColor.red
        } else {
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        leftView.reloadData()
        self.scrollToSectionHeader(collectionView: rightView, section: indexPath.row)
    }
    
    //MARK: - 解决 collectionView 无法定位到段头顶部的方法
    /**
     scrollToItem 只能移动到对应的item位置，不包括section位置
     rightView.scrollToItem(at: IndexPath.init(row: 0, section: indexPath.row), at: .top, animated: true)
     */
    private func scrollToSectionHeader(collectionView: UICollectionView, section: Int) {
        let indexPath = IndexPath.init(row: 0, section: section)
        let attributes = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: indexPath)
        let headerTop = CGPoint(x: 0, y: (attributes?.frame.origin.y)! - collectionView.contentInset.top)
        collectionView .setContentOffset(headerTop, animated: true)
    }
    
}

//MARK: - rightView
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func setupCollectionView() {
        rightView.register(RightSectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "RightSectionHeader")
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categoryNum
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodsNum
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader: RightSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "RightSectionHeader", for: indexPath) as! RightSectionHeader
        sectionHeader.titleLabel.text = "分类\(indexPath.section+1)"
        return sectionHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "RightItem", for: indexPath)
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//MARK: - RightSectionHeader
class RightSectionHeader: UICollectionReusableView {
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel.init(frame: CGRect(x: 15, y: 0, width: self.bounds.size.width - 15*2, height: self.bounds.size.height))
        titleLabel.textColor = UIColor.darkGray
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.brown
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
