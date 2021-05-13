//
//  CustomAdvancedManager.swift
//  testDemo
//
//  Created by 聂飞安 on 2018/9/3.
//  Copyright © 2018年 聂飞安. All rights reserved.
//

import UIKit

@objc public protocol CustomAdvancedScrollViewDelegate: class {
    @objc optional func getscrollViewOffsetY(_ offsetY: CGFloat)
}

@objc public class CustomAdvancedManager: UIView {
    
    public typealias CustomAdvancedDidSelectIndexHandle = (Int) -> Void
    @objc public var advancedDidSelectIndexHandle: CustomAdvancedDidSelectIndexHandle?
    @objc public weak var delegate: CustomAdvancedScrollViewDelegate?
    
    //设置悬停位置Y值
    @objc public var hoverY: CGFloat = 0

   
    
    /* 点击切换滚动过程动画 */
    @objc public var isClickScrollAnimation = false {
        didSet {
            pageView.isClickScrollAnimation = isClickScrollAnimation
        }
    }
    
    /* 代码设置滚动到第几个位置 */
    @objc public func scrollToIndex(index: Int)  {
        pageView.scrollToIndex(index: index)
    }
    
    @objc public func titleSelectToIndex(index: Int)  {
        pageView.titleSelectToIndex(index)
    }
    
    @objc public func setupScrollView()  {
        pageView.upLoadScrollView()
    }
    
    @objc public func setContentSize(_ size : CGSize)
   {
        pageView.setContentSize(size)
   }
    
    @objc public func getcurrentIndex() -> Int
    {
        return pageView.getcurrentIndex
    }
    
    
    private var kHeaderHeight: CGFloat = 0.0
    private var currentSelectIndex: Int = 0
    private var lastDiffTitleToNav:CGFloat = 0.0
    private var headerView: UIView?
    private var viewControllers: [UIViewController]
    private var titles: [String]
    private weak var currentViewController: UIViewController?
    @objc open var pageView: CustomPageView!
   
    
    private var layout: CustomLayout
    
    @objc public init(frame: CGRect, viewControllers: [UIViewController], titles: [String], currentViewController:UIViewController, layout: CustomLayout, headerViewHandle handle: () -> UIView) {
        UIScrollView.initializeOnce()
        UICollectionViewFlowLayout.loadOnce()
        self.viewControllers = viewControllers
        self.titles = titles
        self.currentViewController = currentViewController
        self.layout = layout
        super.init(frame: frame)

        layout.isSinglePageView = true
        pageView = setupPageViewConfig(currentViewController: currentViewController, layout: layout)
        setupSubViewsConfig(handle)
        
    }
    
    deinit {
        deallocConfig()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomAdvancedManager {
    //MARK: 创建PageView
    private func setupPageViewConfig(currentViewController:UIViewController, layout: CustomLayout) -> CustomPageView {
        let pageView = CustomPageView(frame: self.bounds, currentViewController: currentViewController, viewControllers: viewControllers, titles: titles, layout:layout)
        return pageView
    }
}

extension CustomAdvancedManager {
    
    open func setupSubViewsConfig(_ handle: () -> UIView) {
        let headerView = handle()
        kHeaderHeight = headerView.bounds.height
        self.headerView = headerView
        lastDiffTitleToNav = kHeaderHeight
        setupSubViews()
        addSubview(headerView)
//        self.contentOffsetY = -1 * kHeaderHeight
    }
   @objc open func updataSubViewsConfig(_ newHight : CGFloat){
        let oldHight = self.headerView?.bounds.size.height ?? 0
        self.headerView?.isHidden = false
        if oldHight != newHight {
            //如果两个值的高度不一致，将需要更新ui
            let i = newHight - oldHight
            self.pageView.transform = CGAffineTransform.init(translationX: 0, y: i)
        }
        if self.headerView != nil {
            self.headerView?.frame = CGRect(origin: self.headerView!.frame.origin, size: CGSize(width: self.headerView!.frame.size.width, height: newHight))
        } 
    }
    
    private func setupSubViews() {
        pageView.pageTitleView.frame.origin.y = kHeaderHeight
        backgroundColor = UIColor.white
        addSubview(pageView)
        setupPageViewDidSelectItem()
        setupFirstAddChildViewController()
        guard let viewController = viewControllers.first else { return }
        self.contentScrollViewScrollConfig(viewController)
        scrollInsets(viewController, kHeaderHeight+layout.sliderHeight)
    }
    
}


extension CustomAdvancedManager {
    
    //设置ScrollView的contentInset
    private func scrollInsets(_ currentVC: UIViewController ,_ up: CGFloat) {
        currentVC.getscrollView?.contentInset = UIEdgeInsets.init(top: up, left: 0, bottom: 0, right: 0)
        currentVC.getscrollView?.scrollIndicatorInsets = UIEdgeInsets.init(top: up, left: 0, bottom: 0, right: 0)
    }
    
    //MARK: 首次创建pageView的ChildVC回调
    private func setupFirstAddChildViewController() {
        
        //首次创建pageView的ChildVC回调
        pageView.addChildVcBlock = {[weak self] in
            guard let `self` = self else { return }
            let currentVC = self.viewControllers[$0]
            
            //设置ScrollView的contentInset
            self.scrollInsets(currentVC, self.kHeaderHeight+self.layout.sliderHeight)
 
            //初始化滚动回调 首次加载并不会执行内部方法
            self.contentScrollViewScrollConfig($1)
            
            //注意：节流---否则此方法无效。。
            self.setupFirstAddChildScrollView()
        }
        
        if viewControllers.count > 0 {
             pageView.addChildVcBlock?(0, self.viewControllers[0])
        }
       
    }
    
    func getadjustScrollViewContentSizeHeight(getscrollView: UIScrollView?) {
        guard let getscrollView = getscrollView else { return }
        //当前ScrollView的contentSize的高 = 当前ScrollView的的高 避免自动掉落
        let sliderH = self.layout.sliderHeight
        if getscrollView.contentSize.height < getscrollView.bounds.height - sliderH - kHeaderHeight{
            getscrollView.contentSize.height = getscrollView.bounds.height - sliderH - kHeaderHeight
        }
    }
    
    //MARK: 首次创建pageView的ChildVC回调 自适应调节
    private func setupFirstAddChildScrollView() {
        //注意：节流---否则此方法无效。。
        DispatchQueue.main.after(0.01, execute: {
            
            let currentVC = self.viewControllers[self.currentSelectIndex]
            
            guard let getscrollView = currentVC.getscrollView else { return }
            
            self.getadjustScrollViewContentSizeHeight(getscrollView: getscrollView)
            
            getscrollView.contentOffset.y = self.distanceBottomOffset()
            
        })
        
    }
    
    //MARK: 当前的scrollView滚动的代理方法开始
    private func contentScrollViewScrollConfig(_ viewController: UIViewController) {
        
        viewController.getscrollView?.scrollHandle = {[weak self] scrollView in
            
            guard let `self` = self else { return }
            
            let currentVC = self.viewControllers[self.currentSelectIndex]
            
            guard currentVC.getscrollView == scrollView else { return }
            
            self.getadjustScrollViewContentSizeHeight(getscrollView: currentVC.getscrollView)
            
            self.setupgetscrollViewDidScroll(scrollView: scrollView, currentVC: currentVC)
        }
//        if let  scrollView = viewController.getscrollView {
//            viewController.getscrollView?.scrollHandle?(scrollView)
//        }
    }
    
    //MARK: 当前控制器的滑动方法事件处理 1
    private func setupgetscrollViewDidScroll(scrollView: UIScrollView, currentVC: UIViewController)  {
        
        //pageTitleView距离屏幕顶部到pageTitleView最底部的距离
        let distanceBottomOffset = self.distanceBottomOffset()
        
        //当前控制器上一次的偏移量
        let getupOffsetString = currentVC.getupOffset ?? String(describing: distanceBottomOffset)
        
        //先转化为Double(String转CGFloat步骤：String -> Double -> CGFloat)
        let getupOffsetDouble = Double(getupOffsetString) ?? Double(distanceBottomOffset)
        
        //再转化为CGFloat
        let getupOffset = CGFloat(getupOffsetDouble)
        
        //计算上一次偏移和当前偏移量y的差值
        let absOffset = scrollView.contentOffset.y - getupOffset
        if scrollView.contentOffset.y > -kHeaderHeight  || absOffset < 0{
            self.contentScrollViewDidScroll(scrollView, absOffset)
        }
        //记录上一次的偏移量
        currentVC.getupOffset = String(describing: scrollView.contentOffset.y)
        
    }
    
    
    //MARK: 当前控制器的滑动方法事件处理 2
    private func contentScrollViewDidScroll(_ contentScrollView: UIScrollView, _ absOffset: CGFloat)  {
        
        //获取当前控制器
        let currentVc = viewControllers[currentSelectIndex]
        
        //外部监听当前ScrollView的偏移量
        self.delegate?.getscrollViewOffsetY?((currentVc.getscrollView?.contentOffset.y ?? kHeaderHeight) + self.kHeaderHeight + layout.sliderHeight)
        
        //获取偏移量
        let offsetY = contentScrollView.contentOffset.y
        
        //获取当前pageTitleView的Y值
        var pageTitleViewY = pageView.pageTitleView.frame.origin.y
        
        //pageTitleView从初始位置上升的距离
        let titleViewBottomDistance = offsetY + kHeaderHeight + layout.sliderHeight
        
        let headerViewOffset = titleViewBottomDistance + pageTitleViewY
        if absOffset > 0 && titleViewBottomDistance > 0 {//向上滑动
            if headerViewOffset >= kHeaderHeight {
                pageTitleViewY += -absOffset
                if pageTitleViewY <= hoverY {
                    pageTitleViewY = hoverY
                }
            }
        }else{//向下滑动
            if headerViewOffset < kHeaderHeight {
                pageTitleViewY = -titleViewBottomDistance + kHeaderHeight
                if pageTitleViewY >= kHeaderHeight {
                    pageTitleViewY = kHeaderHeight
                }
            }
        }
        
        pageView.pageTitleView.frame.origin.y = pageTitleViewY
        headerView?.frame.origin.y = pageTitleViewY - kHeaderHeight
        let lastDiffTitleToNavOffset = pageTitleViewY - lastDiffTitleToNav
        lastDiffTitleToNav = pageTitleViewY
        //使其他控制器跟随改变
        for subVC in viewControllers {
            getadjustScrollViewContentSizeHeight(getscrollView: subVC.getscrollView)
            guard subVC != currentVc else { continue }
            guard let vcgetscrollView = subVC.getscrollView else { continue }
            vcgetscrollView.contentOffset.y += (-lastDiffTitleToNavOffset)
            subVC.getupOffset = String(describing: vcgetscrollView.contentOffset.y)
        }
    }
    
    private func distanceBottomOffset() -> CGFloat {
        return -(self.pageView.pageTitleView.frame.origin.y + layout.sliderHeight)
    }
}


extension CustomAdvancedManager {
    
    //MARK: pageView选中事件
    private func setupPageViewDidSelectItem()  {
        
        pageView.didSelectIndexBlock = {[weak self] in
            
            guard let `self` = self else { return }
            
            self.setupUpViewControllerEndRefreshing()
            
            self.currentSelectIndex = $1
            
            self.advancedDidSelectIndexHandle?($1)
            
            self.setupContentSizeBoundsHeightAdjust()
            
        }
    }
    
    //MARK: 内容的高度小于bounds 应该让pageTitleView自动回滚到初始位置
    private func setupContentSizeBoundsHeightAdjust()  {
        
        DispatchQueue.main.after(0.01, execute: {
            
            let currentVC = self.viewControllers[self.currentSelectIndex]
            
            guard let getscrollView = currentVC.getscrollView else { return }
            
            self.getadjustScrollViewContentSizeHeight(getscrollView: getscrollView)
            
            //当前ScrollView的contentSize的高
            let contentSizeHeight = getscrollView.contentSize.height
            
            //当前ScrollView的的高
            let boundsHeight = getscrollView.bounds.height - self.layout.sliderHeight
            
            //此处说明内容的高度小于bounds 应该让pageTitleView自动回滚到初始位置
            //这里不用再进行其他操作，因为会调用ScrollViewDidScroll:
            if contentSizeHeight <  boundsHeight {
                let offsetPoint = CGPoint(x: 0, y: -self.kHeaderHeight-self.layout.sliderHeight)
                getscrollView.setContentOffset(offsetPoint, animated: true)
            }
        })
    }
    
    //MARK: 处理下拉刷新的过程中切换导致的问题
//    private func setupUpViewControllerEndRefreshing() {
//        //如果正在下拉，则在切换之前把上一个的ScrollView的偏移量设置为初始位置
//        DispatchQueue.main.after(0.01) {
//            let upVC = self.viewControllers[self.currentSelectIndex]
//            guard let getscrollView = upVC.getscrollView else { return }
//            //判断是下拉
//            if getscrollView.contentOffset.y < (-self.kHeaderHeight-self.layout.sliderHeight) {
//                let offsetPoint = CGPoint(x: 0, y: -self.kHeaderHeight-self.layout.sliderHeight)
//                getscrollView.setContentOffset(offsetPoint, animated: true)
//            }
//        }
//    }
    
    
    public func setupUpViewControllerEndRefreshing() {
        //如果正在下拉，则在切换之前把上一个的ScrollView的偏移量设置为初始位置
        DispatchQueue.main.after(0.01) {
            let upVC = self.viewControllers[self.currentSelectIndex]
            guard let getscrollView = upVC.getscrollView else { return }
            //判断是下拉
            if getscrollView.contentOffset.y < (-self.kHeaderHeight-self.layout.sliderHeight) {
                let offsetPoint = CGPoint(x: 0, y: -self.kHeaderHeight-self.layout.sliderHeight)
                getscrollView.setContentOffset(offsetPoint, animated: true)
            }
        }
    }
    
}

extension CustomAdvancedManager {
    private func deallocConfig() {
        for viewController in viewControllers {
            viewController.getscrollView?.delegate = nil
        }
    }
}
