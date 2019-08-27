//
//  CustomSimpleManager.swift
//  testDemo
//
//  Created by 聂飞安 on 2018/9/3.
//  Copyright © 2018年 聂飞安. All rights reserved.
//


import UIKit

@objc public protocol CustomSimpleScrollViewDelegate: class {
    @objc optional func getscrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func getscrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func getscrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    @objc optional func getscrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func getscrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    @objc optional func getscrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    //刷新tableView的代理方法
    @objc optional func getrefreshScrollView(_ scrollView: UIScrollView, _ index: Int);
    
}

public class CustomSimpleManager: UIView {
    
    /* headerView配置 */
    @objc public func configHeaderView(_ handle: (() -> UIView?)?) {
        guard let handle = handle else { return }
        guard let headerView = handle() else { return }
        kHeaderHeight = CGFloat(Int(headerView.bounds.height))
        headerView.frame.size.height = kHeaderHeight
        self.headerView = headerView
        tableView.tableHeaderView = headerView
    }
    
    /* 动态改变header的高度 */
    @objc public var getheaderHeight: CGFloat = 0.0 {
        didSet {
            kHeaderHeight = getheaderHeight
            headerView?.frame.size.height = kHeaderHeight
            tableView.tableHeaderView = headerView
        }
    }
    
    public typealias CustomSimpleDidSelectIndexHandle = (Int) -> Void
    @objc public var sampleDidSelectIndexHandle: CustomSimpleDidSelectIndexHandle?
    @objc  public func didSelectIndexHandle(_ handle: CustomSimpleDidSelectIndexHandle?) {
        sampleDidSelectIndexHandle = handle
    }
    
    public typealias CustomSimpleRefreshTableViewHandle = (UIScrollView, Int) -> Void
    @objc public var simpleRefreshTableViewHandle: CustomSimpleRefreshTableViewHandle?
    @objc public func refreshTableViewHandle(_ handle: CustomSimpleRefreshTableViewHandle?) {
        simpleRefreshTableViewHandle = handle
    }
    
    /* 代码设置滚动到第几个位置 */
    @objc public func scrollToIndex(index: Int)  {
        pageView.scrollToIndex(index: index)
    }
    
    /* 点击切换滚动过程动画  */
    @objc public var isClickScrollAnimation = false {
        didSet {
            pageView.isClickScrollAnimation = isClickScrollAnimation
        }
    }
    
    //设置悬停位置Y值
    @objc public var hoverY: CGFloat = 0
    
    /* CustomSimple的scrollView上下滑动监听 */
    @objc public weak var delegate: CustomSimpleScrollViewDelegate?
    
    private var contentTableView: UIScrollView?
    private var kHeaderHeight: CGFloat = 0.0
    private var headerView: UIView?
    private var viewControllers: [UIViewController]
    private var titles: [String]
    private weak var currentViewController: UIViewController?
    private var pageView: CustomPageView!
    private var currentSelectIndex: Int = 0
    
    private lazy var tableView: CustomTableView = {
        let tableView = CustomTableView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), style:.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        registerCell(tableView, UITableViewCell.self)
        return tableView
    }()
    
    @objc public init(frame: CGRect, viewControllers: [UIViewController], titles: [String], currentViewController:UIViewController, layout: CustomLayout) {
        UIScrollView.initializeOnce()
        self.viewControllers = viewControllers
        self.titles = titles
        self.currentViewController = currentViewController
        super.init(frame: frame)
        layout.isSinglePageView = true
        pageView = createPageViewConfig(currentViewController: currentViewController, layout: layout)
        createSubViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deallocConfig()
    }
}

extension CustomSimpleManager {
    
    private func createPageViewConfig(currentViewController:UIViewController, layout: CustomLayout) -> CustomPageView {
        let pageView = CustomPageView(frame: self.bounds, currentViewController: currentViewController, viewControllers: viewControllers, titles: titles, layout:layout)
        pageView.delegate = self
        return pageView
    }
}

extension CustomSimpleManager: CustomPageViewDelegate {
    
    public func getscrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.tableView.isScrollEnabled = false
    }
    
    public func getscrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.tableView.isScrollEnabled = true
    }
    
}

extension CustomSimpleManager {
    
    private func createSubViews() {
        backgroundColor = UIColor.white
        addSubview(tableView)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        refreshData()
        pageViewDidSelectConfig()
        guard let viewController = viewControllers.first else { return }
        viewController.beginAppearanceTransition(true, animated: true)
        contentScrollViewScrollConfig(viewController)
    }
    
    /*
     * 当滑动底部tableView的时候，当tableView的contentOffset.y 小于 header的高的时候，将内容ScrollView的contentOffset设置为.zero
     */
    private func contentScrollViewScrollConfig(_ viewController: UIViewController) {
        viewController.getscrollView?.scrollHandle = {[weak self] scrollView in
            guard let `self` = self else { return }
            self.contentTableView = scrollView
            if self.tableView.contentOffset.y  < self.kHeaderHeight - self.hoverY {
                scrollView.contentOffset = CGPoint(x: 0, y: 0)
                scrollView.showsVerticalScrollIndicator = false
            }else{
                scrollView.showsVerticalScrollIndicator = true
            }
        }
    }
    
}

extension CustomSimpleManager {
    private func refreshData()  {
        DispatchQueue.main.after(0.001) {
            UIView.animate(withDuration: 0.34, animations: {
                self.tableView.contentInset = .zero
            })
            self.simpleRefreshTableViewHandle?(self.tableView, self.currentSelectIndex)
            self.delegate?.getrefreshScrollView?(self.tableView, self.currentSelectIndex)
        }
    }
}

extension CustomSimpleManager {
    private func pageViewDidSelectConfig()  {
        pageView.didSelectIndexBlock = {[weak self] in
            guard let `self` = self else { return }
            self.currentSelectIndex = $1
            self.refreshData()
            self.sampleDidSelectIndexHandle?($1)
        }
        pageView.addChildVcBlock = {[weak self] in
            guard let `self` = self else { return }
            self.contentScrollViewScrollConfig($1)
        }
    }
}

extension CustomSimpleManager: UITableViewDelegate {
    
    /*
     * 当滑动内容ScrollView的时候， 当内容contentOffset.y 大于 0（说明滑动的是内容ScrollView） 或者 当底部tableview的contentOffset.y大于 header的高度的时候，将底部tableView的偏移量设置为kHeaderHeight， 并将其他的scrollView的contentOffset置为.zero
     */
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.getscrollViewDidScroll?(scrollView)
        guard scrollView == tableView, let contentTableView = contentTableView else { return }
        let offsetY = scrollView.contentOffset.y
        if contentTableView.contentOffset.y > 0 || offsetY > kHeaderHeight - hoverY {
            tableView.contentOffset = CGPoint(x: 0.0, y: kHeaderHeight - hoverY)
        }
        if scrollView.contentOffset.y < kHeaderHeight - hoverY {
            for viewController in viewControllers {
                guard viewController.getscrollView != scrollView else { continue }
                viewController.getscrollView?.contentOffset = .zero
            }
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.getscrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.getscrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        delegate?.getscrollViewDidEndDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        delegate?.getscrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        delegate?.getscrollViewDidEndScrollingAnimation?(scrollView)
    }
    
}

extension CustomSimpleManager: UITableViewDataSource, CustomTableViewProtocal {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellWithTableView(tableView)
        cell.selectionStyle = .none
        cell.contentView.addSubview(pageView)
        return cell
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
}

extension CustomSimpleManager {
    private func deallocConfig() {
        for viewController in viewControllers {
            viewController.getscrollView?.delegate = nil
        }
    }
}



