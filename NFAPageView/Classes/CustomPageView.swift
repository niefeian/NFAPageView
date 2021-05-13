//
//  CustomPageView.swift
//  testDemo
//
//  Created by 聂飞安 on 2018/9/3.
//  Copyright © 2018年 聂飞安. All rights reserved.
//

import UIKit

public let getiphoneX = (UIScreen.main.bounds.height == 812.0)
private let getsliderDefaultWidth: CGFloat = UIScreen.main.bounds.width/3

@objc open class CustomLayout: NSObject {
    
    /* pageView背景颜色 */
    @objc public var titleViewBgColor: UIColor? = UIColor.white
    
    /* 标题颜色，请使用RGB赋值 */
    @objc public var titleColor: UIColor? = UIColor.gray
    
    /* 剑阁县颜色，请使用RGB赋值 */
    @objc public var lineViewColor: UIColor? = UIColor.clear
    
    /* 标题选中颜色，请使用RGB赋值 */
    @objc public var titleSelectColor: UIColor? = UIColor.black
    
    /* 标题字号 */
    @objc public var titleFont: UIFont? = UIFont.systemFont(ofSize: 15)
    
    
    @objc public var titleSelectFont: UIFont? = UIFont.systemFont(ofSize: 15)
    
    /* 滑块底部线的颜色 - UIColor.blue */
    @objc public var bottomLineColor: UIColor? = UIColor.black
    
    /* 整个滑块的高，pageTitleView的高 */
    @objc public var sliderHeight: CGFloat = 40.0
    
    /* 单个滑块的宽度, 一旦设置，将不再自动计算宽度，而是固定为你传递的值 */
    @objc public var sliderWidth: CGFloat = getsliderDefaultWidth
    
    /*
     * 如果刚开始的布局不希望从最左边开始， 只想平均分配在整个宽度中，设置它为true
     * 注意：此时最左边 lrMargin 以及 titleMargin 仍然有效，如果不需要可以手动设置为0
     */
    @objc public var isAverage: Bool = true
    
    
//    是否隐藏标题
    @objc public var hiddenTitle: Bool = false
    /*
    * 是否允许滚动控制器
    */
    @objc public var isOnlySlider: Bool = false
    
    /* 滑块底部线的高 */
    @objc public var bottomLineHeight: CGFloat = 1.0
    
     /* 滑块底部线的宽  若为0 则根据按钮适配 */
    @objc public var bottomLineWidth: CGFloat = 0
    
    @objc public var bottomLineMarginTop: CGFloat = 0
    
    /* 滑块底部线圆角 */
    @objc public var bottomLineCornerRadius: CGFloat = 0.0
    
    /* 是否隐藏滑块、底部线*/
    @objc public var isHiddenSlider: Bool = false
    
    /* 标题直接的间隔（标题距离下一个标题的间隔）*/
    @objc public var titleMargin: CGFloat = 30.0
    
    /* 距离最左边和最右边的距离 */
    @objc open var lrMargin: CGFloat = 10.0
    
    /* 滑动过程中是否放大标题 */
    @objc public var isNeedScale: Bool = true
    
    /* 放大标题的倍率 */
    @objc public var scale: CGFloat = 1.1
    
    /* 是否开启颜色渐变 */
    @objc public var isColorAnimation: Bool = false
    
    /* 是否隐藏底部线 */
    @objc public var isHiddenPageBottomLine: Bool = false
    
    /* pageView底部线的高度 */
    @objc public var pageBottomLineHeight: CGFloat = 1
    
    /* pageView底部线的颜色 */
    @objc public var pageBottomLineColor: UIColor? = UIColor.lightGray
    
    /* pageView的内容ScrollView是否开启左右弹性效果 */
    @objc public var isShowBounces: Bool = false
    
    /* pageView的内容ScrollView是否开启左右滚动 */
    @objc public var isScrollEnabled: Bool = true
    
    /* pageView的内容ScrollView是否显示HorizontalScrollIndicator */
    @objc public var showsHorizontalScrollIndicator: Bool = true
    
    /* 内部使用-外界不要调用 */
    var isSinglePageView: Bool = false
    
    @objc public weak var delegate: CustomPageViewTitleDelegate?
}

@objc public protocol CustomPageViewTitleDelegate: class {
    @objc optional func titleSelectIndex(_ index : Int) -> Bool
}

public typealias PageViewDidSelectIndexBlock = (CustomPageView, Int) -> Void
public typealias AddChildViewControllerBlock = (Int, UIViewController) -> Void

@objc public protocol CustomPageViewDelegate: class {
    @objc optional func getscrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func getscrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func getscrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    @objc optional func getscrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    @objc optional func getscrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    @objc optional func getscrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
}

@objc public class CustomPageView: UIView {
    
    private weak var currentViewController: UIViewController?
    private var viewControllers: [UIViewController]
    private var titles: [String]
    open var layout: CustomLayout = CustomLayout()
    
    public var getcurrentIndex: Int = 0;
    private var getbuttons: [UIButton] = []
    private var gettextWidths: [CGFloat] = []
    private var getstartOffsetX: CGFloat = 0.0
    private var getclickIndex: Int = 0
    private var isClick: Bool = false
    private var isFirstLoad: Bool = true
    private var getlineWidths: [CGFloat] = []
    
    private var getisClickScrollAnimation = false
    
    @objc public var didSelectIndexBlock: PageViewDidSelectIndexBlock?
    
    @objc public var addChildVcBlock: AddChildViewControllerBlock?
    
    /* 点击切换滚动过程动画  */
    @objc public var isClickScrollAnimation = false
    
    /* pageView的scrollView左右滑动监听 */
    @objc public weak var delegate: CustomPageViewDelegate?
    
    @objc public var titleViewY: CGFloat = 0 {
        didSet {
//            guard let updateY = titleViewY else { return }
            pageTitleView.frame.origin.y = titleViewY
        }
    }
    
    @objc public lazy var pageTitleView: UIView = {
        let pageTitleView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.layout.sliderHeight))
        pageTitleView.backgroundColor = self.layout.titleViewBgColor
        return pageTitleView
    }()
    
    
    
    private lazy var sliderLineView: UIView = {
        
        let sliderLineView = UIView(frame: CGRect(x: self.layout.lrMargin, y: self.pageTitleView.bounds.height - layout.bottomLineHeight - layout.pageBottomLineHeight + layout.bottomLineMarginTop, width: layout.bottomLineWidth, height: self.layout.bottomLineHeight))
        sliderLineView.backgroundColor = self.layout.bottomLineColor
        return sliderLineView
    }()
    
    private lazy var pageBottomLineView: UIView = {
        let pageBottomLineView = UIView(frame: CGRect(x: 0, y: self.pageTitleView.bounds.height - (self.layout.pageBottomLineHeight), width: pageTitleView.bounds.width, height: self.layout.pageBottomLineHeight))
        pageBottomLineView.backgroundColor = self.layout.pageBottomLineColor
        return pageBottomLineView
    }()
    
    /*如果按钮只有一个的话，这边需要在外部重新设置sliderScrollView的值*/
    open lazy var sliderScrollView: UIScrollView = {
        let sliderScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: pageTitleView.bounds.width, height: pageTitleView.bounds.height))
        sliderScrollView.tag = 1403
        sliderScrollView.showsHorizontalScrollIndicator = false
        sliderScrollView.bounces = false
        sliderScrollView.isHidden = layout.hiddenTitle
    
        return sliderScrollView
    }()
    
    
    @objc open func addSliderPageScrollView(pageScrollView : UIView)
    {
        pageTitleView.addSubview(pageScrollView)
//        pageTitleView.isUserInteractionEnabled = true;
//        self.isUserInteractionEnabled = true;
//        pageTitleView.backgroundColor = UIColor.red;
    }
    
    @objc public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
       
        if !layout.isOnlySlider
        {
             scrollView.contentSize = CGSize(width: self.bounds.width * CGFloat(self.titles.count), height: 0)
        }
        else
        {
           scrollView.contentSize = CGSize(width: self.bounds.width, height: 0)
        }
        scrollView.tag = 1302
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = layout.isShowBounces
        scrollView.isScrollEnabled = layout.isScrollEnabled
        scrollView.showsHorizontalScrollIndicator = layout.showsHorizontalScrollIndicator
//        scrollView.backgroundColor = .red;
        return scrollView
    }()

    
    @objc public func setContentSize(_ size : CGSize)
    {
         scrollView.contentSize = size
    }
    
    @objc public init(frame: CGRect, currentViewController: UIViewController, viewControllers:[UIViewController], titles: [String], layout: CustomLayout) {
        self.currentViewController = currentViewController
        self.viewControllers = viewControllers
        self.titles = titles
        self.layout = layout
        guard viewControllers.count == titles.count else {
            fatalError("控制器数量和标题数量不一致")
        }
        super.init(frame: frame)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
            sliderScrollView.contentInsetAdjustmentBehavior = .never
        }
        addSubview(scrollView)
        addSubview(pageTitleView)
       
        pageTitleView.addSubview(sliderScrollView)
        sliderScrollView.addSubview(sliderLineView)
        
        buttonsLayout()
        pageTitleView.addSubview(pageBottomLineView)
        pageTitleView.isHidden = layout.isHiddenPageBottomLine
        sliderLineView.isHidden = layout.isHiddenSlider
        if layout.isHiddenSlider {
            sliderLineView.frame.size.height = 0.0
        }
    }
    
    /* 滚动到某个位置 */
    @objc public func scrollToIndex(index: Int)  {
        var index = index
        if index >= titles.count {
            print("超过最大数量限制, 请正确设置值, 默认这里取第一个")
            index = 0
            return
        }
        
        if isClickScrollAnimation {
            
            let nextButton = getbuttons[index]
            
            if layout.sliderWidth == getsliderDefaultWidth {
                
                if layout.isAverage {
                    let adjustX = (nextButton.frame.size.width - getlineWidths[index]) * 0.5
//                    sliderLineView.frame.origin.x = nextButton.frame.origin.x + adjustX
//                    sliderLineView.frame.size.width = getlineWidths[index]
                    
                    changeSliderLineViewFrame(nextButton.frame.origin.x + adjustX,  getlineWidths[index])
                }else {
//                    sliderLineView.frame.origin.x = nextButton.frame.origin.x
//                    sliderLineView.frame.size.width = nextButton.frame.width
                    
                    changeSliderLineViewFrame(nextButton.frame.origin.x, nextButton.frame.width)
                }
                
            }else {
                if isFirstLoad {
                    setupSliderLineViewWidth(currentButton: getbuttons[index])
                    isFirstLoad = false
                }
            }
        }
        
        setupTitleSelectIndex(index)
        
    }
    
    func changeSliderLineViewFrame(_ x : CGFloat ,_ width : CGFloat)
    {
        if layout.bottomLineWidth > 0
        {
            sliderLineView.frame.origin.x = x + (width - layout.bottomLineWidth)/2
            sliderLineView.frame.size.width  = layout.bottomLineWidth
        }
        else
        {
            sliderLineView.frame.origin.x = x
            sliderLineView.frame.size.width  = width
        }
        
    }
    
    @objc public func upLoadScrollView()  {
        setupScrollView()
    }
        
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CustomPageView {
    
    //初始化按钮
    private func buttonsLayout() {
        
        if titles.count == 0 { return }
        
        // 将所有的宽度计算出来放入数组
        for text in titles {
            
            if layout.isAverage {
                let textAverageW = (pageTitleView.bounds.width - layout.lrMargin * 2.0 - layout.titleMargin * CGFloat(titles.count - 1)) / CGFloat(titles.count)
                gettextWidths.append(textAverageW)
            }else {
                if text.count == 0 {
                    gettextWidths.append(60)
                    getlineWidths.append(60)
                    continue
                }
            }
            
            let textW = text.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: 8), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : layout.titleFont ?? UIFont.systemFont(ofSize: 16)], context: nil).size.width
            
            if !layout.isAverage {
                gettextWidths.append(textW)
            }
            getlineWidths.append(textW)
        }
        
        
        
        // 按钮布局
        var upX: CGFloat = layout.lrMargin
        let subH = pageTitleView.bounds.height - (self.layout.bottomLineHeight)
        let subY: CGFloat = 0
        
        for index in 0..<titles.count {
            
            let subW = gettextWidths[index]
            
            let button = subButton(frame: CGRect(x: upX, y: subY, width: subW, height: subH), flag: index, title: titles[index], parentView: sliderScrollView)
            button.setTitleColor(layout.titleColor, for: .normal)
            button.titleLabel?.font = layout.titleFont
            if index == 0 {
                button.setTitleColor(layout.titleSelectColor, for: .normal)
                button.titleLabel?.font = layout.titleSelectFont
                createViewController(0)
            }
            if titles.count == 4 {
                button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                button.titleLabel?.font = layout.titleFont
                
            }
            
            upX = button.frame.origin.x + subW + layout.titleMargin
            
            getbuttons.append(button)
            
        }
        
        if layout.isNeedScale {
            getbuttons[0].transform = CGAffineTransform(scaleX: layout.scale , y: layout.scale)
        }
        
        // lineView的宽度为第一个的宽度
        if layout.sliderWidth == getsliderDefaultWidth {
            if layout.isAverage {
                 changeSliderLineViewFrame((gettextWidths[0] - getlineWidths[0]) * 0.5 + layout.lrMargin,  getlineWidths[0])
            }else {
                changeSliderLineViewFrame(getbuttons[0].frame.origin.x, getbuttons[0].frame.size.width)
            }
        }else {
              changeSliderLineViewFrame(((gettextWidths[0] + layout.lrMargin * 2) - layout.sliderWidth) * 0.5, layout.sliderWidth)
        }
        
        if layout.bottomLineCornerRadius != 0.0 {
            sliderLineView.layer.cornerRadius = layout.bottomLineCornerRadius
            sliderLineView.layer.masksToBounds = true
            sliderLineView.clipsToBounds = true
        }
        
        if layout.isAverage {
            sliderScrollView.contentSize = CGSize(width: pageTitleView.bounds.width, height: 0)
            return
        }
        
        
        // 计算sliderScrollView的contentSize
        let sliderContenSizeW = upX - layout.titleMargin + layout.lrMargin
        
        if sliderContenSizeW < scrollView.bounds.width {
            sliderScrollView.frame.size.width = sliderContenSizeW
        }
        
        //最后多加了一个 layout.titleMargin， 这里要减去
        sliderScrollView.contentSize = CGSize(width: sliderContenSizeW, height: 0)
        
    }
    
    @objc private func titleSelectIndex(_ btn: UIButton)  {
        titleSelectToIndex(btn.tag)
    }
    
    @objc public func titleSelectToIndex(_ toIndex: Int)  {
        if layout.delegate?.titleSelectIndex?(toIndex) ?? true {
            setupTitleSelectIndex(toIndex)
        }
        else
        {
            if layout.isOnlySlider
            {
                chengSliderLineView(toIndex)
            }
        }
    }
    
    
    
    private func chengSliderLineView(_ btnSelectIndex : Int)
    {
        let nextButton = getbuttons[btnSelectIndex]
        let adjustX = (nextButton.frame.size.width - getlineWidths[btnSelectIndex]) * 0.5
        changeSliderLineViewFrame(nextButton.frame.origin.x + adjustX,  getlineWidths[btnSelectIndex])
        
        setupSlierScrollToCenter(offsetX: adjustX, index: btnSelectIndex)
        if !isClickScrollAnimation
        {
            for button in getbuttons {
                if button.tag == btnSelectIndex {
                   button.setTitleColor(self.layout.titleSelectColor, for: .normal)
                   button.titleLabel?.font = layout.titleSelectFont
                }else {
                   button.setTitleColor(self.layout.titleColor, for: .normal)
                   button.titleLabel?.font = layout.titleFont
                }
            }
        }
        else
        {
            setupIsClickScrollAnimation(index: btnSelectIndex)
        }
       
    }
    
    private func setupTitleSelectIndex(_ btnSelectIndex: Int) {
        
        if (getcurrentIndex == btnSelectIndex && btnSelectIndex != 0) || scrollView.isDragging || scrollView.isDecelerating {
             if layout.isOnlySlider
             {
                chengSliderLineView(btnSelectIndex)
            }
            return
        }
        
        let totalW = bounds.width
       
        if totalW * CGFloat(btnSelectIndex) == scrollView.contentOffset.x
        {
             chengSliderLineView(btnSelectIndex)
            return
        }
        else
        {
            isClick = true
            getisClickScrollAnimation = true
            scrollView.setContentOffset(CGPoint(x: totalW * CGFloat(btnSelectIndex), y: 0), animated: isClickScrollAnimation)
        }
       
        if isClickScrollAnimation {
            return
        }
        
        let nextButton = getbuttons[btnSelectIndex]
        
        if layout.sliderWidth == getsliderDefaultWidth {
            
            if layout.isAverage {
                let adjustX = (nextButton.frame.size.width - getlineWidths[btnSelectIndex]) * 0.5
//                sliderLineView.frame.origin.x = nextButton.frame.origin.x + adjustX
//                sliderLineView.frame.size.width = getlineWidths[btnSelectIndex]
                
                changeSliderLineViewFrame(nextButton.frame.origin.x + adjustX,  getlineWidths[btnSelectIndex])
            }else {
//                sliderLineView.frame.origin.x = nextButton.frame.origin.x
//                sliderLineView.frame.size.width = nextButton.frame.width
                
                 changeSliderLineViewFrame(nextButton.frame.origin.x,  nextButton.frame.width)
            }
            
        }else {
            setupSliderLineViewWidth(currentButton: nextButton)
        }
        
        getcurrentIndex = btnSelectIndex
        
    }
    
    
    private func setupScrollView(){
        scrollView.setContentOffset(CGPoint(x:scrollView.contentOffset.x, y: 0), animated: isClickScrollAnimation)
    }
    
    
    // currentButton将要滚动到的按钮
    private func setupSliderLineViewWidth(currentButton: UIButton)  {
        let maxLeft = currentButton.frame.origin.x - layout.lrMargin
        let maxRight = maxLeft + layout.lrMargin * 2 + currentButton.frame.size.width
        let originX = (maxRight - maxLeft - layout.sliderWidth) * 0.5  + maxLeft
//        sliderLineView.frame.origin.x = originX
//        sliderLineView.frame.size.width = layout.sliderWidth
        
        changeSliderLineViewFrame(originX,  layout.sliderWidth)
    }
    
}

extension CustomPageView {
    
    private func createViewController(_ index: Int)  {
        let VC = viewControllers[index]
        guard let currentViewController = currentViewController else { return }
        if currentViewController.children.contains(VC) {
            return
        }
        var viewControllerY: CGFloat = 0.0
        layout.isSinglePageView ? viewControllerY = 0.0 : (viewControllerY = layout.sliderHeight)
        if viewControllers.count == 4 {
            viewControllerY = 30
        }
        
        VC.view.frame = CGRect(x: scrollView.bounds.width * CGFloat(index), y: viewControllerY, width: scrollView.bounds.width, height: scrollView.bounds.height - viewControllerY)
        scrollView.addSubview(VC.view)
        currentViewController.addChild(VC)
        VC.automaticallyAdjustsScrollViewInsets = false
        addChildVcBlock?(index, VC)
        if let getscrollView = VC.getscrollView {
            if #available(iOS 11.0, *) {
                getscrollView.contentInsetAdjustmentBehavior = .never
            }
            getscrollView.frame.size.height = getscrollView.frame.size.height - viewControllerY
        }
    }
    
    private func scrollViewDidScrollOffsetX(_ offsetX: CGFloat)  {
        
        _ = setupLineViewX(offsetX: offsetX)
        
        let index = currentIndex()
        
        if getcurrentIndex != index {
            
            //如果开启滚动动画
            if isClickScrollAnimation {
                //如果不是点击事件继续在这个地方设置偏移
                if !getisClickScrollAnimation {
                    setupSlierScrollToCenter(offsetX: offsetX, index: index)
                }
            }else {
                //设置滚动的位置
                setupSlierScrollToCenter(offsetX: offsetX, index: index)
            }
            
            // 如果是点击的话
            if isClick {
                
                let upButton = getbuttons[getcurrentIndex]
                
                let currentButton = getbuttons[index]
                
                if layout.isNeedScale {
                    UIView.animate(withDuration: 0.2, animations: {
                        currentButton.transform = CGAffineTransform(scaleX: self.layout.scale , y: self.layout.scale)
                        upButton.transform = CGAffineTransform(scaleX: 1.0 , y: 1.0 )
                    })
                }
                
                setupButtonStatusAnimation(upButton: upButton, currentButton: currentButton)
                
            }
            
            if layout.isColorAnimation == false {
                let upButton = getbuttons[getcurrentIndex]
                let currentButton = getbuttons[index]
                setupButtonStatusAnimation(upButton: upButton, currentButton: currentButton)
            }
            
            //如果开启滚动动画
            if isClickScrollAnimation {
                //如果不是点击事件继续在这个地方设置偏移
                if !getisClickScrollAnimation {
                    
                    createViewController(index)
                    
                    didSelectIndexBlock?(self, index)
                }
            }else {
                //默认的设置
                createViewController(index)

                didSelectIndexBlock?(self, index)
            }
            
            getcurrentIndex = index
            
        }
        isClick = false
        
    }
    
    private func setupIsClickScrollAnimation(index: Int) {
        if !isClickScrollAnimation {
            return
        }
        for button in getbuttons {
            if button.tag == index {
                if layout.isNeedScale {
                    button.transform = CGAffineTransform(scaleX: layout.scale , y: layout.scale)
                }
                button.setTitleColor(self.layout.titleSelectColor, for: .normal)
                button.titleLabel?.font = layout.titleSelectFont
            }else {
                if layout.isNeedScale {
                    button.transform = CGAffineTransform(scaleX: 1.0 , y: 1.0)
                }
                button.setTitleColor(self.layout.titleColor, for: .normal)
                button.titleLabel?.font = layout.titleFont
            }
        }
        getisClickScrollAnimation = false
    }
    
    private func setupButtonStatusAnimation(upButton: UIButton, currentButton: UIButton)  {
        upButton.setTitleColor(layout.titleColor, for: .normal)
        currentButton.setTitleColor(layout.titleSelectColor, for: .normal)
        
        upButton.titleLabel?.font = layout.titleFont
        currentButton.titleLabel?.font = layout.titleSelectFont
        
    }
    
    //MARK: 让title的ScrollView滚动到中心点位置
    private func setupSlierScrollToCenter(offsetX: CGFloat, index: Int)  {
        
        let currentButton = getbuttons[index]
        
        let btnCenterX = currentButton.center.x
        
        var scrollX = btnCenterX - sliderScrollView.bounds.width * 0.5
        
        if scrollX < 0 {
            scrollX = 0
        }
        
        if scrollX > sliderScrollView.contentSize.width - sliderScrollView.bounds.width {
            scrollX = sliderScrollView.contentSize.width - sliderScrollView.bounds.width
        }
        
        sliderScrollView.setContentOffset(CGPoint(x: scrollX, y: 0), animated: true)
    }
    
    //MARK: 设置线的移动
    private func setupLineViewX(offsetX: CGFloat) -> Bool {
        
        if isClick {
            return false
        }
        
        
        //目的是改变它的值，让制滑动第一个和最后一个的时候（-0.5），导致数组下标越界
        var offsetX = offsetX
        
        let scrollW = scrollView.bounds.width
        
        // 目的是滑动到最后一个的时候 不让其再往后滑动
        if offsetX + scrollW >= scrollView.contentSize.width {
            if layout.sliderWidth == getsliderDefaultWidth {
                let adjustX = (gettextWidths.last! - getlineWidths.last!) * 0.5
                sliderLineView.frame.origin.x = layout.lrMargin + adjustX
            }else {
                setupSliderLineViewWidth(currentButton: getbuttons.last!)
            }
            offsetX = scrollView.contentSize.width - scrollW - 0.5
        }
        
        // 目的是滑动到第一个的时候 不让其再往前滑动
        if offsetX <= 0 {
            if layout.sliderWidth == getsliderDefaultWidth {
                let adjustX = (gettextWidths[0] - getlineWidths[0]) * 0.5
                sliderLineView.frame.origin.x = layout.lrMargin + adjustX
            }else {
                sliderLineView.frame.origin.x = ((gettextWidths[0] + layout.lrMargin * 2) - layout.sliderWidth) * 0.5
            }
            offsetX = 0.5
        }
        
        var nextIndex = Int(offsetX / scrollW)
        
        var sourceIndex = Int(offsetX / scrollW)
        
        //向下取整 目的是减去整数位，只保留小数部分
        var progress = (offsetX / scrollW) - floor(offsetX / scrollW)
        
        if offsetX > getstartOffsetX { // 向左滑动
            
            //向左滑动 下个位置比源位置下标 多1
            nextIndex = nextIndex + 1
            
        }else { // 向右滑动
            
            //向右滑动 由于源向下取整的缘故 必须补1 nextIndex则恰巧是原始位置
            sourceIndex = sourceIndex + 1
            
            progress = 1 - progress
            
        }
        
        let nextButton = getbuttons[nextIndex]
        
        let currentButton = getbuttons[sourceIndex]
        
       
        if layout.isColorAnimation {
            if nextIndex > sourceIndex {
                let previouNex = lroundf(Float(offsetX / scrollW))
                if   sourceIndex > 0 && previouNex != 3{
                   let previousButton = getbuttons[sourceIndex-1]
                    previousButton.setTitleColor(layout.titleColor, for: .normal)
                    currentButton.setTitleColor(layout.titleSelectColor, for: .normal)
                    
                    previousButton.titleLabel?.font = layout.titleFont
                    currentButton.titleLabel?.font = layout.titleSelectFont
                }else{
                    currentButton.setTitleColor(layout.titleColor, for: .normal)
                    nextButton.setTitleColor(layout.titleSelectColor, for: .normal)
                    
                    currentButton.titleLabel?.font = layout.titleFont
                    nextButton.titleLabel?.font = layout.titleSelectFont
                }
            }else{
                currentButton.setTitleColor(layout.titleColor, for: .normal)
                nextButton.setTitleColor(layout.titleSelectColor, for: .normal)
                
                currentButton.titleLabel?.font = layout.titleFont
                nextButton.titleLabel?.font = layout.titleSelectFont
            }

        }
        
        if layout.isNeedScale {
            let scaleDelta = (layout.scale - 1.0) * progress
            currentButton.transform = CGAffineTransform(scaleX: layout.scale - scaleDelta, y: layout.scale - scaleDelta)
            nextButton.transform = CGAffineTransform(scaleX: 1.0 + scaleDelta, y: 1.0 + scaleDelta)
        }
        
        // 判断是否是自定义Slider的宽度（这里指没有自定义）
        if layout.sliderWidth == getsliderDefaultWidth {
            
            if layout.isAverage {
                /*
                 * 原理：（按钮的宽度 - 线的宽度）/ 2 = 线的X便宜量
                 * 如果是不是平均分配 按钮的宽度 = 线的宽度
                 */
                // 计算宽度的该变量
                let moveW = getlineWidths[nextIndex] - getlineWidths[sourceIndex]
                
                // （按钮的宽度 - 线的宽度）/ 2
                let nextButtonAdjustX = (nextButton.frame.size.width - getlineWidths[nextIndex]) * 0.5
                
                // （按钮的宽度 - 线的宽度）/ 2
                let currentButtonAdjustX = (currentButton.frame.size.width - getlineWidths[sourceIndex]) * 0.5
                
                // x的该变量
                let moveX = (nextButton.frame.origin.x + nextButtonAdjustX) - (currentButton.frame.origin.x + currentButtonAdjustX)
                
//                self.sliderLineView.frame.size.width = getlineWidths[sourceIndex] + moveW * progress
//
//                self.sliderLineView.frame.origin.x = currentButton.frame.origin.x + moveX * progress + currentButtonAdjustX
                
                changeSliderLineViewFrame(currentButton.frame.origin.x + moveX * progress + currentButtonAdjustX,  getlineWidths[sourceIndex] + moveW * progress)
                
            }else {
                // 计算宽度的该变量
                let moveW = nextButton.frame.width - currentButton.frame.width
                
                // 计算X的该变量
                let moveX = nextButton.frame.origin.x - currentButton.frame.origin.x
                
//                self.sliderLineView.frame.size.width = currentButton.frame.width + moveW * progress
//                self.sliderLineView.frame.origin.x = currentButton.frame.origin.x + moveX * progress - 0.25
                
                changeSliderLineViewFrame(currentButton.frame.origin.x + moveX * progress - 0.25,  currentButton.frame.width + moveW * progress)
            }
            
        }else {
            
            
            /*
             * 原理：按钮的最左边X（因为有lrMargin，这里必须减掉） 以及 按钮的相对右边X（注意不是最右边，因为每个按钮的X都有一个lrMargin， 所以相对右边则有两个才能保证按钮的位置，这个和titleMargin无关）
             */
            let maxNextLeft = nextButton.frame.origin.x - layout.lrMargin
            let maxNextRight = maxNextLeft + layout.lrMargin * 2.0 + nextButton.frame.size.width
            let originNextX = (maxNextRight - maxNextLeft - layout.sliderWidth) * 0.5 + maxNextLeft
            
            let maxLeft = currentButton.frame.origin.x - layout.lrMargin
            let maxRight = maxLeft + layout.lrMargin * 2.0 + currentButton.frame.size.width
            let originX = (maxRight - maxLeft - layout.sliderWidth) * 0.5 + maxLeft
            
            let moveX = originNextX - originX
            
//            self.sliderLineView.frame.origin.x = originX + moveX * progress
//            
//            sliderLineView.frame.size.width = layout.sliderWidth
            
            changeSliderLineViewFrame(originX + moveX * progress,  layout.sliderWidth)
        }
        
        return false
    }
    
    private func currentIndex() -> Int {
        if scrollView.bounds.width == 0 || scrollView.bounds.height == 0 {
            return 0
        }
        let index = Int((scrollView.contentOffset.x + scrollView.bounds.width * 0.5) / scrollView.bounds.width)
        return max(0, index)
    }
    
}

extension CustomPageView {
    
    private func getRGBWithColor(_ color : UIColor) -> (CGFloat, CGFloat, CGFloat) {
        guard let components = color.cgColor.components else {
            fatalError("请使用RGB方式给标题颜色赋值")
        }
        return (components[0] * 255, components[1] * 255, components[2] * 255)
    }
}

extension UIColor {
    
    public convenience init(r : CGFloat, g : CGFloat, b : CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1.0)
    }
}

extension CustomPageView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.getscrollViewDidScroll?(scrollView)
        let offsetX = scrollView.contentOffset.x
        scrollViewDidScrollOffsetX(offsetX)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.getscrollViewWillBeginDragging?(scrollView)
        getstartOffsetX = scrollView.contentOffset.x
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
        if getisClickScrollAnimation {
            let index = currentIndex()
            createViewController(index)
            setupSlierScrollToCenter(offsetX: scrollView.contentOffset.x, index: index)
            setupIsClickScrollAnimation(index: index)
            didSelectIndexBlock?(self, index)
        }
        
    }
}

extension CustomPageView {
    
    @discardableResult
    private func subButton(frame: CGRect, flag: Int, title: String?, parentView: UIView) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.tag = flag
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(titleSelectIndex(_:)), for: .touchUpInside)
        button.titleLabel?.font = layout.titleFont
        parentView.addSubview(button)
        if flag > 0 {
            let lineView = UIView(frame: CGRect(x: frame.origin.x -  0.5, y: 5, width: 1, height: frame.size.height - 10))
            lineView.backgroundColor = layout.lineViewColor
            parentView.addSubview(lineView)
        }
        return button
    }
    
}

